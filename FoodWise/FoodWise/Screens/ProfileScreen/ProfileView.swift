//
//  ProfileView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 18.12.2025.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var isKithenSharePresented: Bool = false
    @State private var isJoinKitchenPresented: Bool = false
    
    
    let peachColor = Color(red: 249/255, green: 188/255, blue: 154/255)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.signOut()
                    }) {
                        Text("Log out")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(peachColor)
                            .cornerRadius(20)
                    }
                    .accessibilityIdentifier("logout_button")
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 25) {
                        VStack(spacing: 15) {
                            Text(viewModel.state.userName)
                                .font(.system(size: 22, weight: .bold, design: .serif))
                            
                            
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray.opacity(0.3))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.top, 10)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Preferences:")
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .padding(.horizontal) // Zarovná nadpis s okrajem obrazovky
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(viewModel.state.availablePreferences) { item in
                                        OptionCircleView(
                                            item: item,
                                            isSelected: viewModel.state.selectedPreferences.contains(item.title)
                                        )
                                        .onTapGesture {
                                            viewModel.togglePreference(item.title)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Restriction:")
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(viewModel.state.availableRestrictions) { item in
                                        OptionCircleView(
                                            item: item,
                                            isSelected: viewModel.state.selectedRestrictions.contains(item.title)
                                        )
                                        .onTapGesture {
                                            viewModel.toggleRestriction(item.title)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Share Kitchen:")
                                .font(.system(size: 20, weight: .bold, design: .serif))
                            
                            Text("More than one person cooking or shopping? Share your kitchen with friends & family to sync devices and manage the kitchen together.")
                                .font(.footnote)
                                .foregroundColor(.black)
                                .lineSpacing(4)
                            
                            Button(action: {
                                isKithenSharePresented = true
                            }) {
                                Text("Share Kitchen (Show Code)")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(peachColor)
                                    .cornerRadius(25)
                            }
                            .padding(.top, 10)
                            
                            
                            Button(action: {
                                isJoinKitchenPresented = true
                            }) {
                                Text("Join a Kitchen (Enter Code)")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(peachColor, lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .sheet(isPresented: $isKithenSharePresented) {
            ShareKitchenSheet()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isJoinKitchenPresented) {
            JoinKitchenSheet()
                .presentationDetents([.medium])
        }
        
        .onAppear {
            viewModel.fetchUserProfile()
        }
        .onChange(of: viewModel.state.isLoggedOut) { oldValue, loggedOut in
            if loggedOut {
                
                print("User logged out - Switch to Login Screen")
            }
        }
    }
}




struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
