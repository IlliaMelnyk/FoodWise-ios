//
//  UserProfile.swift
//  FoodWise
//
//  Created by Illia Melnyk on 23.12.2025.
//
import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var uid: String?
    var name: String?
    var email: String?
    var avatarImage: String?
    var householdId: String?
    
    var displayNameSafe: String {
        return name ?? "User"
    }
}
