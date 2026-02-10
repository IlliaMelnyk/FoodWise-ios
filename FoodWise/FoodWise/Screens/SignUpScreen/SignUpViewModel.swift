//
//  SignUpView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Observation

@Observable
class SignUpViewModel {
    var state = SignUpViewState()
    private let db = Firestore.firestore()
    
    func signUp() {
        // --- Validation Logic ---
        guard !state.fullName.isEmpty,
              !state.email.isEmpty,
              !state.password.isEmpty,
              !state.confirmPassword.isEmpty else {
            state.errorMessage = "Please fill in all fields."
            return
        }
        
        guard state.password == state.confirmPassword else {
            state.errorMessage = "Passwords do not match."
            return
        }
        
        guard state.password.count >= 6 else {
             state.errorMessage = "Password must be at least 6 characters."
             return
        }

        state.isLoading = true
        state.errorMessage = nil
        
        Auth.auth().createUser(withEmail: state.email, password: state.password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.state.isLoading = false
                    self.state.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let user = authResult?.user else { return }
       
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = state.fullName
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Error updating profile: \(error.localizedDescription)")
                }
            }
            
     
            let userData: [String: Any] = [
                "name": state.fullName,
                "avatarImage": "person.crop.circle.fill",
                "dietaryPreferences": [] as [String]
            ]
            
            db.collection("users").document(user.uid).setData(userData) { error in
                DispatchQueue.main.async {
                    self.state.isLoading = false
                    
                    if let error = error {
                        self.state.errorMessage = "Account created but failed to save data: \(error.localizedDescription)"
                    } else {
                        print("User and Firestore document created successfully!")
                        self.state.isSignedUp = true
                    }
                }
            }
        }
    }
}
