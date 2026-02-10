//
//  AuthManager.swift
//  FoodWise
//
//  Created by Illia Melnyk on 16.12.2025.
//


import Foundation
import FirebaseAuth
import SwiftUI

@Observable
class AuthManager {
    var user: FirebaseAuth.User?
    var isLoading: Bool = true
    
    init() {
            Auth.auth().addStateDidChangeListener { [weak self] auth, user in
                self?.user = user
                self?.isLoading = false
                print("Auth State Changed: User is \(user == nil ? "Logged Out" : "Logged In")")
            }
        }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
}
