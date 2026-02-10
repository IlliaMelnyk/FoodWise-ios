//
//  RecipesView.swift
//  FoodWise
//
//  Created by Illia Melnyk on 16.12.2025.
//

import SwiftUI

import SwiftUI

struct RecipesView: View {
    @EnvironmentObject var kitchenViewModel: KitchenListViewModel
    @StateObject private var viewModel = RecipesViewModel()
    
    let dietaryUpdateNotification = NotificationCenter.default.publisher(for: .dietaryProfileChanged)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    if kitchenViewModel.state.products.isEmpty {
                        EmptyFridgeView()
                            .accessibilityIdentifier("empty_fridge_view")
                    }
                    else if viewModel.isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .accessibilityIdentifier("recipes_loading_indicator")
                            Text("The chef is thinking...")
                                .font(.headline)
                            Text("Creating recipes from your ingredients...")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    }
                    else if let error = viewModel.errorMessage {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text(error)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    else {
                   
                        if !viewModel.readyToCook.isEmpty {
                            RecipeSection(title: "Ready to Cook ", recipes: viewModel.readyToCook)
                                .accessibilityIdentifier("ready_to_cook_section")
                        }
                        
                     
                        if !viewModel.expiringSoon.isEmpty {
                            RecipeSection(title: "Use Up Soon ", recipes: viewModel.expiringSoon)
                        }
                        
                        if !viewModel.needMoreIngredients.isEmpty {
                            RecipeSection(title: "Need More Ingredients ", recipes: viewModel.needMoreIngredients)
                        }
                        
                        if viewModel.readyToCook.isEmpty && viewModel.expiringSoon.isEmpty && viewModel.needMoreIngredients.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("Unfortunately, no recipes could be generated.")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 40)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Recipes")
            
           
            .onAppear {
               
                if !kitchenViewModel.state.products.isEmpty && viewModel.readyToCook.isEmpty {
                    viewModel.loadRecipes(from: kitchenViewModel.state.products)
                }
            }
        }
 
        .onReceive(dietaryUpdateNotification) { _ in
            print("Notification received! Reloading recipes...")
       
            if !kitchenViewModel.state.products.isEmpty {
                viewModel.loadRecipes(from: kitchenViewModel.state.products)
            }
        }
    }
}



