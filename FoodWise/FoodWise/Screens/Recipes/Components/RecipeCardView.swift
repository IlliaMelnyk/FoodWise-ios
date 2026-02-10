//
//  RecipeCardView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 15.01.2026.
//

import Foundation
import SwiftUI
struct RecipeCardView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: recipe.imageUrl ?? "")) { phase in
                if let image = phase.image {
                    image.resizable()
                         .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Color.gray
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 160, height: 160)
            .clipped()
            .cornerRadius(12)
            
            Text(recipe.name)
                .font(.headline)
                .lineLimit(2)
                .frame(height: 50, alignment: .top)
            
            Text(recipe.time)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .accessibilityIdentifier("recipe_card_\(recipe.name)")
        .frame(width: 160)
    }
}
