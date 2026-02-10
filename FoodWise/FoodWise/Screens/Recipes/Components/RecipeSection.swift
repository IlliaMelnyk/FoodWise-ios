//
//  RecipeSection.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 15.01.2026.
//

import Foundation
import SwiftUI

struct RecipeSection: View {
    let title: String
    let recipes: [Recipe]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(recipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeCardView(recipe: recipe)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
