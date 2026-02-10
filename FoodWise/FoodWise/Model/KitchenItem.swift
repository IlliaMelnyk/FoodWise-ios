//
//  KitchenItem.swift
//  FoodWise
//
//  Created by Illia Melnyk on 16.12.2025.
//


import Foundation
#if os(iOS)
import FirebaseFirestore
#endif

struct KitchenItem: Identifiable, Codable {
    
    #if os(iOS)
    @DocumentID var id: String?
    #else
    var id: String?
    #endif
    
    var householdId: String?
    var name: String
    var quantity: Int
    var unit: String
    var pieces: Int
    var expiryDate: Date
    var category: String
    var status: KitchenItemStatus?
    
    var actionDate: Date?
    
    var daysLeft: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expiryDate)
        return components.day ?? 0
    }
    var isExpired: Bool {
        daysLeft < 0
    }
}

enum KitchenItemStatus: String, Codable {
    case active  
    case used
    case wasted
}

extension KitchenItem {
    func expiryStatus(for date: Date = Date()) -> String {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: date)
        let startOfExpiry = calendar.startOfDay(for: self.expiryDate)
        
        let daysLeft = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiry).day ?? 0
        
        if daysLeft < 0 { return "Expired" }
        if daysLeft <= 3 { return "Warning" }
        return "OK" 
    }
}
