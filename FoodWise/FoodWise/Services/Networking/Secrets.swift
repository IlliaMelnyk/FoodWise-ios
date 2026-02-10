//
//  Secrets.swift
//  FoodWise
//
//  Created by Illia Melnyk on 18.12.2025.
//


import Foundation

struct Secrets {
    static func get(_ key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) else {
            print("Error: File Secrets.plist not found or unable to read!")
            return nil
        }
        
        let value = dict[key] as? String
        if value == nil {
            print("Error: Key '\(key)' in Secrets.plist missing!")
        }
        return value
    }
}
