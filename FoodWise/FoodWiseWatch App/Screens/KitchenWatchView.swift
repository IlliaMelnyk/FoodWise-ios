//
//  KitchenWatchView.swift
//  FoodWiseWatch Watch App
//
//  Created by Illia Melnyk on 02.01.2026.
//

import SwiftUI

struct KitchenWatchView: View {
    @ObservedObject var connector: PhoneConnector
    
    var body: some View {
        NavigationStack {
            content
        }
        .onAppear {
            connector.requestDataFromPhone()
        }
    }
    
    @ViewBuilder
    var content: some View {
        if connector.receivedKitchenItems.isEmpty {
            VStack {
                Image(systemName: "refrigerator")
                    .font(.largeTitle)
                    .padding()
                Text("Kitchen is empty")
                    .font(.headline)
                Text("Add items on iPhone")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        } else {
            List {
                ForEach(connector.receivedKitchenItems) { item in
                    KitchenItemRow(item: item)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                connector.consumeItem(item)
                            } label: {
                                Label("Consumed", systemImage: "fork.knife")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                connector.wasteItem(item)
                            } label: {
                                Label("Wasted", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("My Kitchen")
        }
    }
}

struct KitchenItemRow: View {
    let item: KitchenItem
    
    var expiryColor: Color {
        let calendar = Calendar.current
        
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfExpiry = calendar.startOfDay(for: item.expiryDate)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiry)
        let daysLeft = components.day ?? 0
        
        if daysLeft < 0 {
            return .red
        } else if daysLeft <= 3 {
            return .orange
        } else {
            return .green
        }
    }
    
    var expiryText: String {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfExpiry = calendar.startOfDay(for: item.expiryDate)
        let days = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiry).day ?? 0
        
        if days < 0 { return "Expired" }
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return "\(days) days"
    }
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(expiryColor)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                
                HStack {
                    Text("\(item.quantity) \(item.unit)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(expiryText)
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(expiryColor)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
