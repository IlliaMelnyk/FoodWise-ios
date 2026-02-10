//
//  JoinKitchenSheet.swift
//  FoodWise
//
//  Created by Illia Melnyk on 23.12.2025.
//


import SwiftUI

struct JoinKitchenSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var householdService = KitchenHouseholdService.shared
    @State private var joinCode: String = ""
    @State private var isJoining = false
    @State private var errorMessage: String?
    
    let peachColor = Color(red: 249/255, green: 188/255, blue: 154/255)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                
                Image(systemName: "person.3.sequence.fill")
                    .font(.system(size: 60))
                    .foregroundColor(peachColor)
                    .padding(.top, 40)
                
                VStack(spacing: 10) {
                    Text("Join a Household")
                        .font(.title2)
                        .bold()
                        .fontDesign(.serif)
                    
                    Text("Enter the 6-character code shared by your family member or friend.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                TextField("Enter Code (e.g. A1B2C3)", text: $joinCode)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .textCase(.uppercase)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(isJoining)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: joinHousehold) {
                    if isJoining {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Join Kitchen")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 50)
                .background(joinCode.count < 3 ? Color.gray.opacity(0.3) : peachColor)
                .foregroundColor(.white)
                .foregroundColor(joinCode.count < 3 ? .gray : .black)
                .cornerRadius(25)
                .padding(.horizontal)
                .disabled(joinCode.count < 3 || isJoining)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    func joinHousehold() {
        isJoining = true
        errorMessage = nil
        
        Task {
            let success = await householdService.joinHousehold(code: joinCode.uppercased())
            await MainActor.run {
                isJoining = false
                if success {
                    dismiss() 
                } else {
                    errorMessage = "Invalid code or connection error."
                }
            }
        }
    }
}
