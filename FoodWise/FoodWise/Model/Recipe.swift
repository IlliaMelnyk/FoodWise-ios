//
//  Recipe.swift
//  FoodWise
//
//  Created by Illia Melnyk on 18.12.2025.
//


import Foundation


import Foundation

struct IngredientItem: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let quantity: String
    
    enum CodingKeys: String, CodingKey {
        case name = "nazev"
        case quantity = "mnozstvi"
    }
}

struct Recipe: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let time: String
    
    let ingredients: [IngredientItem]
    let missingIngredients: [IngredientItem]?
    let imageKeywords: String
    let instructions: String
    var imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case name = "nazev"
        case imageKeywords = "image_keywords"
        case time = "cas"
        case ingredients = "pouzite_suroviny"
        case missingIngredients = "chybejici_suroviny"
        case instructions = "postup"
    }
}

struct GeminiRecipeResponse: Decodable {
    let readyToCook: [Recipe]
    let expiringSoon: [Recipe]
    let needMoreIngredients: [Recipe]
    
    enum CodingKeys: String, CodingKey {
        case readyToCook = "ready_to_cook"
        case expiringSoon = "expiring_soon"
        case needMoreIngredients = "need_more_ingredients"
    }
}
