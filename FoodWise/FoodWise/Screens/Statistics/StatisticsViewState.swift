//
//  WasteStatisticItem.swift
//  FoodWise
//
//  Created by Illia Melnyk on 19.12.2025.
//


import Foundation

struct WasteStatisticItem: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let count: Int
    let maxCount: Int
}

struct StatisticsViewState {
    var thrownOutCount: Int = 0
    var usedCount: Int = 0
    var scorePercentage: Double = 0.0
    var topWastedItems: [WasteStatisticItem] = []
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
}