

//
//  ShoppingItemRow.swift
//  FoodWise
//
//  Created by Illia Melnyk on 22.12.2025.
//
import SwiftUI

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "basket")
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.body)
                    .strikethrough(item.isCompleted, color: .gray)
                    .foregroundColor(item.isCompleted ? .gray : .primary)
                
                if !item.quantity.isEmpty {
                    Text(item.quantity)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .opacity(item.isCompleted ? 0.6 : 1.0)
    }
}
