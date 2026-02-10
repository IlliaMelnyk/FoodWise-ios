//
//  RecipeDetailView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.01.2026.
//



import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    
    @StateObject private var shoppingViewModel = ShoppingViewModel()
    @State private var showAddedAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                ZStack {
                    Color.gray.opacity(0.2)
                    
                    if let imageUrl = recipe.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                ProgressView()
                            }
                        }
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 300)
                .clipped()
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text(recipe.name)
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)

                    if !recipe.ingredients.isEmpty {
                        Text("Ingredients you have:")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            ForEach(recipe.ingredients) { item in
                                IngredientRow(
                                    icon: "checkmark.circle.fill",
                                    name: item.name,
                                    quantity: item.quantity,
                                    isMissing: false
                                )
                            }
                        }
                    }

                    if let missing = recipe.missingIngredients, !missing.isEmpty {
                        Text("Ingredients to buy:")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        VStack(spacing: 12) {
                            ForEach(missing) { item in
                                IngredientRow(
                                    icon: "cart.badge.plus",
                                    name: item.name,
                                    quantity: item.quantity,
                                    isMissing: true
                                )
                            }
                        }
                        
                        Button(action: {
                            addMissingItemsToCart(items: missing)
                            showAddedAlert = true
                        }) {
                            HStack {
                                Image(systemName: "cart.fill.badge.plus")
                                Text("Add \(missing.count) items to Shopping List")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.8))
                            .cornerRadius(25)
                        }
                        .padding(.vertical)
                        .alert("Success", isPresented: $showAddedAlert) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text("Items have been added to your shopping list.")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.title2)
                            .fontDesign(.serif)
                            .bold()
                        
                        Text(recipe.instructions)
                            .font(.body)
                            .lineSpacing(6)
                            .foregroundColor(.primary.opacity(0.9))
                    }
                }
                .padding(24)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            shoppingViewModel.fetchShoppingLists()
        }
    }
    
    private func addMissingItemsToCart(items: [IngredientItem]) {
        shoppingViewModel.addIngredientsFromRecipeToDefaultList(ingredients: items)
    }
}

struct IngredientRow: View {
    let icon: String
    let name: String
    let quantity: String
    let isMissing: Bool
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isMissing ? Color.orange.opacity(0.1) : Color.green.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(isMissing ? .orange : .green)
            }
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(quantity)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
