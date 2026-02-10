//
//  WasteRowView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 15.01.2026.
//

import Foundation
import SwiftUI

struct WasteRowView: View {
    let item: WasteStatisticItem
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(rankColor(rank: item.rank))
                    .frame(width: 32, height: 32)
                
                Text("\(item.rank)")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
            }
            
            Text(item.name)
                .font(.body)
                .bold()
                .fontDesign(.serif)
                .frame(width: 90, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    let width = CGFloat(item.count) / CGFloat(item.maxCount) * geometry.size.width
                    
                    Capsule()
                        .fill(rankBarColor(rank: item.rank))
                        .frame(width: width, height: 6)
                }
                .frame(height: 6)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            
            Text("\(item.count)x")
                .font(.subheadline)
                .bold()
                .foregroundColor(.gray)
                .frame(width: 40, alignment: .trailing)
        }
    }
    
    func rankColor(rank: Int) -> Color {
        switch rank {
        case 1: return Color.red
        case 2: return Color(red: 0.8, green: 0.5, blue: 0.5)
        case 3: return Color(red: 0.7, green: 0.6, blue: 0.5)
        default: return Color.gray.opacity(0.5)
        }
    }
    
    func rankBarColor(rank: Int) -> Color {
        return Color.red
    }
}
