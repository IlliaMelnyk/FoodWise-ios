//
//  SignInViewState.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import SwiftUI

struct SignInView: View {
    @State private var viewModel = SignInViewModel()
    
    let peachColor = Color(red: 249/255, green: 188/255, blue: 154/255)
    let orangeLinkColor = Color(red: 216/255, green: 89/255, blue: 43/255)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 25) {
                    
                    
                    VStack(spacing: 10) {
                        Text("Sign In")
                            .font(.system(size: 32, weight: .bold, design: .serif))
                            .foregroundColor(.black)
                        
                        Text("Enter your email and password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 50)
                    
                    
                    VStack(spacing: 20) {
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email").font(.caption).foregroundColor(.gray)
                            
                            TextField("", text: $viewModel.state.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            Divider()
                        }
                        
             
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Password").font(.caption).foregroundColor(.gray)
                                Spacer()
                                Button("Forgot password?") { }
                                    .font(.caption).bold()
                                    .foregroundColor(orangeLinkColor)
                            }
                            
                            SecureField("", text: $viewModel.state.password)
                            
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    
                    Button(action: {
                        viewModel.signIn()
                    }) {
                        ZStack {
                            if viewModel.state.isLoading {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text("Login")
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
                    .disabled(viewModel.state.isLoading)
                    
                    
                    HStack(spacing: 5) {
                        Text("Dont have an account?")
                            .foregroundColor(.black)
                        
                        
                        NavigationLink(destination: SignUpView().navigationBarBackButtonHidden(true)) {
                            Text("Sign up")
                                .fontWeight(.bold)
                                .foregroundColor(orangeLinkColor)
                                .underline()
                        }
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
            
//            .onChange(of: viewModel.state.isLoggedIn) { oldValue, newValue in
//                if newValue {
//                    print("Navigate to Home Screen")
//                }
//            }
        }
    }
}
