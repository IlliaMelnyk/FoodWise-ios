//
//  WatchPayloads.swift
//  FoodWise
//
//  Created by Illia Melnyk on 09.01.2026.
//


import Foundation

struct KitchenItemPayload: Encodable {
    let id: String?
    let householdId: String?
    let name: String
    let quantity: Int
    let unit: String
    let pieces: Int
    let expiryDate: Date
    let category: String
    let statusRawValue: String?
    
    enum CodingKeys: String, CodingKey {
        case id, householdId, name, quantity, unit, pieces, expiryDate, category
        case statusRawValue = "status"
    }
}

struct ShoppingListPayload: Encodable {
    let id: String?
    let name: String
    let date: Date
    let ownerId: String
    let members: [String]
    let inviteCode: String?
}

struct ShoppingItemPayload: Encodable {
    let id: String?
    let listId: String
    let name: String
    let quantity: String
    let isCompleted: Bool
}
