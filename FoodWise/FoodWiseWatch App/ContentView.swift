//
//  ContentView.swift
//  FoodWiseWatchApp Watch App
//
//  Created by Illia Melnyk on 02.01.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var phoneConnector = PhoneConnector()
    
    var body: some View {
        TabView {
            KitchenWatchView(connector: phoneConnector)
                .tabItem {
                    Label("Kitchen", systemImage: "refrigerator")
                }
            
            ShoppingWatchView(connector: phoneConnector)
                .tabItem {
                    Label("Shopping", systemImage: "cart")
                }
        }
    }
}

#Preview {
    ContentView()
}
