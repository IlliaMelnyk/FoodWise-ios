//
//  EmptyFridgeView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 15.01.2026.
//

import Foundation
import SwiftUI

struct EmptyFridgeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "basket")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Your kitchen is empty")
                .font(.title3)
                .bold()
            
            Text("Add some ingredients to your list first so we can figure out what to cook.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }
}
