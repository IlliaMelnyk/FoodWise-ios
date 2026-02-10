//
//  ProfileViewState.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 18.12.2025.
//

import Foundation

import Observation
import SwiftUI
import Foundation
import FirebaseAuth

struct DietaryOption: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let color: Color
    let isStrikethrough: Bool
}

@Observable
class ProfileViewState {
    var userName: String = "Illia Melnyk"
    var userAvatar: String = "person.crop.circle.fill"
    var isLoggedOut: Bool = false
    var errorMessage: String? = nil
    var members: [FirebaseAuth.User] = []
    
    var selectedPreferences: Set<String> = []
    var selectedRestrictions: Set<String> = []

    
   
    let availablePreferences: [DietaryOption] = [
            DietaryOption(title: "Vegan", iconName: "leaf.fill", color: Color(red: 249/255, green: 188/255, blue: 154/255), isStrikethrough: false),
            DietaryOption(title: "Vegetarian", iconName: "carrot.fill", color: Color(red: 249/255, green: 188/255, blue: 154/255), isStrikethrough: false),
            DietaryOption(title: "Pork free", iconName: "pawprint.fill", color: Color(red: 249/255, green: 188/255, blue: 154/255), isStrikethrough: true),
            DietaryOption(title: "No beef", iconName: "pawprint.fill", color: Color(red: 249/255, green: 188/255, blue: 154/255), isStrikethrough: true)
        ]
        
        let availableRestrictions: [DietaryOption] = [
            DietaryOption(title: "Gluten Free", iconName: "laurel.leading", color: Color(red: 249/255, green: 188/255, blue: 154/255), isStrikethrough: true),
            DietaryOption(title: "No lactose", iconName: "drop.fill", color: Color(red: 249/255, green: 188/255, blue: 154/255), isStrikethrough: true),
            DietaryOption(title: "No Alcohol", iconName: "wineglass.fill", color: Color(red: 249/255, green: 188/255, blue: 154/255), isStrikethrough: true)
    ]
}
