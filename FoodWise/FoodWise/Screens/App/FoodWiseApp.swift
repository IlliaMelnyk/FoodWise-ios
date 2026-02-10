//
//  FoodWiseApp.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    return true
  }
}

@main
struct FoodWiseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var authManager: AuthManager

    init() {
        FirebaseApp.configure()
    
        _authManager = State(initialValue: AuthManager())
        print("FoodWise App Initialized Correctly")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .preferredColorScheme(.light)
        }
    }
}
