//
//  ContentView.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) var authManager
    

    @State private var isShowingSplash = true
    
    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
            } else {
 
                Group {
                    if authManager.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    } else if authManager.user != nil {
                        MainTabView()
                    } else {
                        SignInView()
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isShowingSplash)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                isShowingSplash = false
            }
        }
    }
}
