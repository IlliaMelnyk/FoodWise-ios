//
//  SignInViewState.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import Foundation
import FirebaseAuth

@Observable
class SignInViewModel {
    var state = SignInViewState()
    
    func signIn() {
        guard !state.email.isEmpty, !state.password.isEmpty else {
            state.errorMessage = "Please fill in all fields."
            return
        }
        
        state.isLoading = true
        state.errorMessage = nil
        
        Auth.auth().signIn(withEmail: state.email, password: state.password) { [weak self] result, error in
            guard let self = self else { return }
            
    
            DispatchQueue.main.async {
                self.state.isLoading = false
                
                if let error = error {
                    self.state.errorMessage = error.localizedDescription
                } else {
                    print("Success: \(result?.user.uid ?? "Unknown")")
                    self.state.isLoggedIn = true
                }
            }
        }
    }
}
