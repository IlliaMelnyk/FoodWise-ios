
//
//  ShoppingListCard.swift
//  FoodWise
//
//  Created by Illia Melnyk on 22.12.2025.
//
import SwiftUI

struct ShoppingListCard: View {
    let list: ShoppingList
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(list.name)
                    .font(.title3)
                    .fontDesign(.serif)
                    .bold()
                
                if list.members.count > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                        Text("Shared")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Text(list.formattedDate)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
