//
//  SignInViewState.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import Foundation
import Observation

@Observable
class SignInViewState {
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String? = nil
    var isLoggedIn = false
}
