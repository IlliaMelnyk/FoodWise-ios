//
//  ScoreCardView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 15.01.2026.
//

import Foundation
import SwiftUI

struct ScoreCardView: View {
    let state: StatisticsViewState
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(red: 86/255, green: 181/255, blue: 126/255))
                .frame(height: 160)
            
            HStack(spacing: 0) {
                StatColumn(title: "Thrown out", value: "\(state.thrownOutCount)")
                
                ZStack {
                    VStack(spacing: 4) {
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 8)
                            
                            Circle()
                                .trim(from: 0, to: state.scorePercentage)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut, value: state.scorePercentage)
                            
                            Text("\(Int(state.scorePercentage * 100))%")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(width: 70, height: 70)
                    }
                }
                .frame(maxWidth: .infinity)
                
                StatColumn(title: "Used", value: "\(state.usedCount)")
            }
        }
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
