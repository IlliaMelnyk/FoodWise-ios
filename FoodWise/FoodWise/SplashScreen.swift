//
//  SplashScreen.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 18.12.2025.
//

import Foundation

import SwiftUI

struct SplashView: View {
    @State private var opacity = 0.5
    @State private var size = 0.8
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
               
                Image("food-wise-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 220, height: 220)
                

                VStack(spacing: 10) {
                    Text("FoodWise")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundColor(.black)
                    
                    Text("Your smart assistant\nagainst food waste")
                        .font(.system(size: 18, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .lineSpacing(4)
                }
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.0)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
            }
        }
    }
}
