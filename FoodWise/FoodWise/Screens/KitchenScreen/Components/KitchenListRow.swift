//
//  KitchenListRow.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import Foundation
import SwiftUI

struct KitchenListRow: View {
    let item: KitchenItem
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: iconForCategory(item.category))
                    .foregroundStyle(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text("\(item.pieces)x ~\(item.quantity)\(item.unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text(daysText(days: item.daysLeft))
                }
                .font(.callout)
                .fontWeight(.bold)
                .foregroundStyle(expiryColor(days: item.daysLeft))
            }
        }
        .padding(.vertical, 4)
        .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(item.isExpired ? Color.red : Color.clear, lineWidth: 2)
                        .background(item.isExpired ? Color.red.opacity(0.05) : Color.clear)
        )
    }
    
    func expiryColor(days: Int) -> Color {
        if days < 0 { return .gray }
        if days <= 2 { return .red }
        if days <= 5 { return .orange }
        return .green 
    }
    
    func daysText(days: Int) -> String {
        if days < 0 { return "Expired" }
        if days == 0 { return "Today" }
        return "\(days) days"
    }
    
    func iconForCategory(_ cat: String) -> String {
        switch cat {
        case "Dairy": return "drop.fill"
        case "Meat": return "hare.fill"
        default: return "circle.fill"
        }
    }
}
