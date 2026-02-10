//
//  StatColumn.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 15.01.2026.
//

import Foundation
import SwiftUI


struct StatColumn: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}
