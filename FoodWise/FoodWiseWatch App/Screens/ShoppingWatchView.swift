//
//  ShoppingWatchView.swift
//  FoodWiseWatch Watch App
//
//  Created by Illia Melnyk on 02.01.2026.
//

import SwiftUI

struct ShoppingWatchView: View {
    @ObservedObject var connector: PhoneConnector
    
    var body: some View {
        NavigationStack {
            if connector.receivedShoppingLists.isEmpty {
                VStack {
                    Image(systemName: "cart.badge.questionmark")
                        .font(.largeTitle)
                    Text("No Lists")
                    Text("Create one on iPhone")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            } else {
                List {
                    ForEach(connector.receivedShoppingLists) { list in
                        NavigationLink {
                            ShoppingItemsView(connector: connector, listId: list.id ?? "", listName: list.name)
                        } label: {
                            HStack {
                                Image(systemName: "list.bullet.clipboard")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text(list.name)
                                        .font(.headline)
                                    Text(list.formattedDate)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Shopping Lists")
            }
        }
        .onAppear {
            if connector.receivedShoppingLists.isEmpty {
                connector.requestDataFromPhone()
            }
        }
    }
}

struct ShoppingItemsView: View {
    @ObservedObject var connector: PhoneConnector
    let listId: String
    let listName: String
    
    var body: some View {
        VStack {
            if connector.receivedShoppingItems.isEmpty {
                VStack {
                    ProgressView()
                    Text("Loading items...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                List {
                    ForEach(connector.receivedShoppingItems) { item in
                        Button {
                            connector.toggleItem(item)
                        } label: {
                            HStack {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isCompleted ? .green : .gray)
                                    .font(.title3)
                                
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .strikethrough(item.isCompleted)
                                        .foregroundColor(item.isCompleted ? .gray : .primary)
                                    
                                    if !item.quantity.isEmpty {
                                        Text(item.quantity)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle(listName)
        .onAppear {
            connector.receivedShoppingItems = [] 
            connector.requestItems(for: listId)
        }
    }
}
