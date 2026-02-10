//
//  ShoppingDetailView.swift
//  FoodWise
//
//  Created by Illia Melnyk on 22.12.2025.
//

import Foundation
import SwiftUI

struct ShoppingDetailView: View {
    @ObservedObject var viewModel: ShoppingViewModel
    let list: ShoppingList
    
    @State private var showingShareSheet = false
    @State private var isAddingItem = false
    @State private var newItemName = ""
    @State private var newItemQuantity = ""
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.state.currentItems) { item in
                        ShoppingItemRow(item: item) {
                            viewModel.toggleItemCompletion(item: item)
                        }
                    }
                }
                .padding()
            }
            
        
        }
        .navigationTitle(list.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAddingItem = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 28))
                        .foregroundColor(.orange)
                    
                }
            }
            
        }
        .sheet(isPresented: $showingShareSheet) {
            ListShareSheet(list: list)
        }
        .alert("New Item", isPresented: $isAddingItem) {
            TextField("Name (e.g. Milk)", text: $newItemName)
            TextField("Quantity (e.g. 1L)", text: $newItemQuantity)
            Button("Add") {
                if !newItemName.isEmpty {
                    viewModel.addItem(listId: list.id ?? "", name: newItemName, quantity: newItemQuantity)
                    newItemName = ""
                    newItemQuantity = ""
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .onAppear {
            viewModel.fetchItems(for: list.id ?? "")
        }
        .onDisappear {
            viewModel.stopListening()
            viewModel.fetchShoppingLists()
        }
    }
}
