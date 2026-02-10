//
//  SignUpView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    @State private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) var dismiss
    
    let peachColor = Color(red: 249/255, green: 188/255, blue: 154/255)
    let orangeLinkColor = Color(red: 216/255, green: 89/255, blue: 43/255)
    let eyeIconColor = Color(red: 216/255, green: 89/255, blue: 43/255)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 25) {
                
                VStack(spacing: 10) {
                    Text("Sign Up")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(.black)
                    
                    Text("Fist creat your account") 
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                .padding(.bottom, 20)
                
           
                VStack(spacing: 20) {
    
                    InputView(title: "Full name", text: $viewModel.state.fullName)
            
                    InputView(title: "Email", text: $viewModel.state.email, keyboardType: .emailAddress)
                    
                    PasswordInputView(
                        title: "Password",
                        text: $viewModel.state.password,
                        isVisible: $viewModel.state.isPasswordVisible,
                        iconColor: eyeIconColor
                    )
                    
                    PasswordInputView(
                        title: "Confirm your password",
                        text: $viewModel.state.confirmPassword,
                        isVisible: $viewModel.state.isConfirmPasswordVisible,
                        iconColor: eyeIconColor
                    )
                }
                .padding(.horizontal)
                
          
                Button(action: {
                    viewModel.signUp()
                }) {
                    ZStack {
                        if viewModel.state.isLoading {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("Sign up")
                                .font(.system(size: 18, weight: .medium, design: .serif))
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(peachColor)
                    .cornerRadius(30)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .disabled(viewModel.state.isLoading)
                
      
                HStack(spacing: 5) {
                    Text("Already have an account?")
                        .foregroundColor(.black)
                    Button("Login") {
                        dismiss() // Go back to the previous screen
                    }
                    .fontWeight(.bold)
                    .foregroundColor(orangeLinkColor)
                    .underline()
                }
                .font(.footnote)
                
                Spacer()
            }
            .padding()
        }

        .alert("Error", isPresented: Binding(
            get: { viewModel.state.errorMessage != nil },
            set: { _ in viewModel.state.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.state.errorMessage ?? "")
        }

        .onChange(of: viewModel.state.isSignedUp) { oldValue, newValue in
            if newValue {
                //print("Navigate to Home Screen (or auto-login)")
            }
        }
    }
}




// Preview
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
