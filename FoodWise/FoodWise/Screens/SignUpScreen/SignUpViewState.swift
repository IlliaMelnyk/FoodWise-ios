//
//  SignUpViewState.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import Foundation
import Observation

@Observable
class SignUpViewState {
    var fullName = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    var isPasswordVisible = false
    var isConfirmPasswordVisible = false
    
    var isLoading = false
    var errorMessage: String? = nil
    var isSignedUp = false 
}
