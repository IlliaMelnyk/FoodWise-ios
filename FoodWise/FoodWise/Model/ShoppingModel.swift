//
//  ShoppingModel.swift
//  FoodWise
//
//  Created by Illia Melnyk on 19.12.2025.
//

import Foundation
#if os(iOS)
import FirebaseFirestore
#endif

struct ShoppingList: Identifiable, Codable {
    #if os(iOS)
    @DocumentID var id: String?
    #else
    var id: String?
    #endif
    var name: String
    var date: Date
    
    var ownerId: String
    var members: [String]
    var inviteCode: String?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct ShoppingItem: Identifiable, Codable {
    #if os(iOS)
    @DocumentID var id: String?
    #else
    var id: String?
    #endif
    var listId: String
    
    var name: String
    var quantity: String
    var isCompleted: Bool
    var addedByUserId: String?
}
