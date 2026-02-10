//
//  ShareKitchenSheet.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.01.2026.
//


import Foundation
import FirebaseAuth
import SwiftUI

struct ShareKitchenSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var householdService = KitchenHouseholdService.shared
    @State private var showLeaveAlert = false
    @State private var isLeaving = false
    
    let peachColor = Color(red: 249/255, green: 188/255, blue: 154/255)
    let grayBackground = Color(UIColor.systemGray6)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(grayBackground)
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Current members:")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(.black)
                        
                        if householdService.members.isEmpty {
                            ProgressView()
                        } else {
                            ForEach(householdService.members, id: \.uid) { user in
                                HStack(spacing: 12) {
                                    if let avatar = user.avatarImage, !avatar.isEmpty {
                                        if avatar.hasPrefix("http") {
                                            AsyncImage(url: URL(string: avatar)) { image in
                                                image.resizable().aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Color.gray
                                            }
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                        } else {
                                            Image(systemName: avatar)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.gray)
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                        }
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                            .frame(width: 50, height: 50)
                                    }
                                    
                                    Text(user.displayNameSafe)
                                        .font(.system(size: 18, weight: .medium, design: .serif))
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Invite new member:")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                        
                        VStack(alignment: .center) {
                            Text("JOIN CODE")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(householdService.inviteCode)
                                .font(.system(size: 32, design: .monospaced))
                                .fontWeight(.bold)
                                .padding(10)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)

                        HStack(spacing: 15) {
                            Button(action: {
                                UIPasteboard.general.string = householdService.inviteCode
                            }) {
                                Text("Copy Code")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(peachColor)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    
                    Divider()
                    
                    Button(action: {
                        showLeaveAlert = true
                    }) {
                        HStack {
                            if isLeaving {
                                ProgressView()
                            } else {
                                Image(systemName: "door.left.hand.open")
                                Text("Leave Kitchen")
                            }
                        }
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .disabled(isLeaving)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.white)
        .onAppear {
            Task {
                await householdService.initializeHousehold()
            }
        }
        .alert("Leave Kitchen?", isPresented: $showLeaveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                isLeaving = true
                Task {
                    let success = await householdService.leaveCurrentHousehold()
                    if success {
                        dismiss()
                    }
                    isLeaving = false
                }
            }
        } message: {
            Text("Are you sure? You will be removed from this group and a new personal kitchen will be created for you.")
        }
    }
}
