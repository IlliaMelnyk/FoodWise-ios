//
//  ExpiredActionSheet.swift
//  FoodWise
//
//  Created by Illia Melnyk on 17.12.2025.
//


import SwiftUI

struct ExpiredActionSheet: View {
    let item: KitchenItem
    var onConsumed: () -> Void
    var onWasted: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            Spacer()
            
            Text("\(item.name) has been expired")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("What happened to it?")
                .font(.headline)
                .foregroundColor(.gray)
            
            VStack(spacing: 15) {
                Button(action: onConsumed) {
                    Text("Ate it")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 180/255, green: 220/255, blue: 180/255)) 
                        .cornerRadius(30)
                }
                
                Button(action: onWasted) {
                    Text("Wasted it")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 180/255, green: 90/255, blue: 90/255))
                        .cornerRadius(30)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
