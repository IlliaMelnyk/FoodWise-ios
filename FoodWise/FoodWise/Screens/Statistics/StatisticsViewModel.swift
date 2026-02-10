//
//  StatisticsViewModel.swift
//  FoodWise
//
//  Created by Illia Melnyk on 19.12.2025.
//

import Foundation
import Combine
import FirebaseFirestore

class StatisticsViewModel: ObservableObject {
    
    @Published var state = StatisticsViewState()
    
    private var db = Firestore.firestore()
    private let aiService = GoogleAIStudioService()
    private let householdService = KitchenHouseholdService.shared
    
    private var listener: ListenerRegistration?
    
    func startListening() {
        stopListening()
        
        state.isLoading = true
        state.errorMessage = nil
        
        Task {
            if householdService.currentHouseholdId == nil {
                await householdService.initializeHousehold()
            }
            
            guard let householdId = householdService.currentHouseholdId else {
                await MainActor.run {
                    self.state.isLoading = false
                    self.state.errorMessage = "Chyba: Nepodařilo se identifikovat vaši domácnost."
                }
                return
            }
            
            let query = db.collection("kitchen")
                .whereField("householdId", isEqualTo: householdId)
                .whereField("status", in: ["used", "wasted"])
            
            listener = query.addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.state.errorMessage = "Chyba DB: \(error.localizedDescription)"
                        self.state.isLoading = false
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async { self.state.isLoading = false }
                    return
                }
                
                let items = documents.compactMap { try? $0.data(as: KitchenItem.self) }
                
                Task {
                    await self.calculateStatsWithAI(from: items)
                }
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    @MainActor
    private func calculateStatsWithAI(from items: [KitchenItem]) async {
        let wastedItems = items.filter { $0.status == .wasted }
        let usedItems = items.filter { $0.status == .used }
        
        let wastedCount = wastedItems.count
        let usedCount = usedItems.count
        let total = Double(wastedCount + usedCount)
        let score: Double = total > 0 ? Double(usedCount) / total : 0.0
        
        self.state.thrownOutCount = wastedCount
        self.state.usedCount = usedCount
        self.state.scorePercentage = score
        
        if wastedItems.isEmpty {
            self.state.topWastedItems = []
            self.state.isLoading = false
            return
        }
        
        do {
            let wastedNames = wastedItems.map { $0.name }
            // AI analýza může chvíli trvat
            let groups = try await aiService.analyzeWaste(items: wastedNames)
            
            let topGroups = groups.prefix(5)
            let maxVal = topGroups.first?.count ?? 1
            
            self.state.topWastedItems = topGroups.enumerated().map { (index, group) in
                WasteStatisticItem(
                    rank: index + 1,
                    name: group.categoryName,
                    count: group.count,
                    maxCount: maxVal
                )
            }
            
        } catch {
            print("AI selhalo nebo není dostupné, počítám lokálně.")
            self.calculateLocalFallback(wastedItems: wastedItems)
        }
        
        self.state.isLoading = false
    }
    
    private func calculateLocalFallback(wastedItems: [KitchenItem]) {
        let groupedWaste = Dictionary(grouping: wastedItems, by: { item in
            let clean = item.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return clean.components(separatedBy: " ").first ?? clean
        })
        
        let sortedWaste = groupedWaste
            .sorted { $0.value.count > $1.value.count }
            .prefix(5)
        
        let maxVal = sortedWaste.first?.value.count ?? 1
        
        self.state.topWastedItems = sortedWaste.enumerated().map { (index, element) in
            let niceName = element.value.first?.name ?? element.key.capitalized
            return WasteStatisticItem(
                rank: index + 1,
                name: niceName.capitalized,
                count: element.value.count,
                maxCount: maxVal
            )
        }
    }
}
