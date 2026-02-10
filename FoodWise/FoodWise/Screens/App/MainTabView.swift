//
//  MainTabView.swift
//  FoodWise
//
//  Created by Illia Melnyk on 16.12.2025.
//


import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var kitchenViewModel = KitchenListViewModel()
    var body: some View {
        TabView(selection: $selectedTab) {
            
            KitchenListView()
                .tabItem {
                    Label("Kitchen", systemImage: "refrigerator")
                }
                .tag(0)
                .accessibilityIdentifier("Kitchen")
    
            ShoppingView()
                .tabItem {
                    Label("Shopping", systemImage: "cart")
                }
                .tag(1)
                .accessibilityIdentifier("Shopping")
            
            RecipesView()
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }
                .tag(2)
                .accessibilityIdentifier("Recipes")
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.xaxis")
                }
                .tag(3)
                .accessibilityIdentifier("Statistics")
        }
        .tint(.orange)
        .environmentObject(kitchenViewModel)
    }
}
