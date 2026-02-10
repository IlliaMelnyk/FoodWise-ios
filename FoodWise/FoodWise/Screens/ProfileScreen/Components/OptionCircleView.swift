//
//  OptionCircleView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 15.01.2026.
//

import Foundation
import SwiftUI

struct OptionCircleView: View {
    let item: DietaryOption
    let isSelected: Bool
    
    
    let activeGreen = Color(red: 144/255, green: 238/255, blue: 144/255)
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                
                Circle()
                    .fill(isSelected ? activeGreen.opacity(0.6) : item.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                
                Circle()
                    .stroke(isSelected ? activeGreen : item.color, lineWidth: 2)
                    .frame(width: 60, height: 60)
                
                Image(systemName: item.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
                
                
                if item.isStrikethrough {
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 2, height: 50)
                        .rotationEffect(.degrees(45))
                }
            }
            
            Text(item.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
    
    
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
