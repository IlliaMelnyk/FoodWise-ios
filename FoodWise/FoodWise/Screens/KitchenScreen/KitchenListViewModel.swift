// KitchenListViewModel.swift

import Foundation
import Observation
import FirebaseFirestore
import Combine

class KitchenListViewModel: ObservableObject {
    @Published var state = KitchenListViewState()
        
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    private let householdService = KitchenHouseholdService.shared
    
    private var cancellables = Set<AnyCancellable>()
    private let watchConnector = WatchConnector.shared
    
    init() {
        setupKitchen()
        
        householdService.$currentHouseholdId
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newHouseholdId in
                if let newId = newHouseholdId {
                    print("Zmena domacnosti detekovana (Combine): \(newId)")
                    self?.startListening(householdId: newId)
                }
            }
            .store(in: &cancellables)
    }
        
    deinit {
        listenerRegistration?.remove()
        cancellables.removeAll()
    }
    
    func setupKitchen() {
        print("SetupKitchen startuje...")
        state.isLoading = true
        
        Task {
            await householdService.initializeHousehold()
            
            if let householdId = householdService.currentHouseholdId {
                print("Domacnost nalezena: \(householdId), spoustim listener.")
                await MainActor.run {
                    startListening(householdId: householdId)
                }
            } else {
                print("Domacnost NENI nalezena.")
                await MainActor.run {
                    state.isLoading = false
                    state.errorMessage = "Nepodarilo se nacist domacnost."
                }
            }
        }
    }
    
    func startListening(householdId: String) {
        print("Startuji listener pro: \(householdId)")
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("kitchen")
            .whereField("householdId", isEqualTo: householdId)
            .whereField("status", isEqualTo: "active")
            .order(by: "expiryDate", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("CHYBA LISTENERU: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("Zadne dokumenty")
                    return
                }
                
                print("PRIJATA DATA: \(documents.count) polozek")
                
                DispatchQueue.main.async {
                    self.state.products = documents.compactMap { document in
                        try? document.data(as: KitchenItem.self)
                    }
                    self.state.isLoading = false
                    
                    self.watchConnector.sendKitchenData(items: self.state.products)
                }
            }
    }
    
    func addItem(name: String, quantity: Int, unit: String, pieces: Int, expiryDate: Date, category: String) {
        guard let householdId = householdService.currentHouseholdId else {
            print("CHYBA: Pokus o pridani polozky bez householdId!")
            state.errorMessage = "Chyba: Nepodarilo se nacist vasi domacnost. Zkuste se odhlasit a prihlasit."
            return
        }
        
        print("Pridavam polozku do domacnosti: \(householdId)")
        
        let newItem = KitchenItem(
            householdId: householdId,
            name: name,
            quantity: quantity,
            unit: unit,
            pieces: pieces,
            expiryDate: expiryDate,
            category: category,
            status: .active
        )
        
        do {
            try db.collection("kitchen").addDocument(from: newItem)
            print("Odeslano do Firestore")
        } catch {
            print("Chyba pri odesilani: \(error)")
            state.errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
    
    func markAsConsumed(item: KitchenItem) {
        updateStatus(item: item, newStatus: "used")
    }
    
    func markAsWasted(item: KitchenItem) {
        updateStatus(item: item, newStatus: "wasted")
    }
    
    private func updateStatus(item: KitchenItem, newStatus: String) {
        guard let id = item.id else { return }
        
        db.collection("kitchen").document(id).updateData([
            "status": newStatus,
            "actionDate": Date()
        ])
    }
    
    func addItemsFromOCR(_ aiItems: [AIReceiptItem], targetHouseholdId: String? = nil) {
        let idToUse = targetHouseholdId ?? householdService.currentHouseholdId
        
        guard let householdId = idToUse else {
            print("CHYBA: Pokus o přidání položky bez householdId!")
            return
        }
        let today = Date()
        
        for item in aiItems {
            let newId = UUID().uuidString
            
            let estimatedExpiry = Calendar.current.date(byAdding: .day, value: item.days, to: today) ?? today
            
            let newItem = KitchenItem(
                id: newId,
                householdId: householdId,
                name: item.name,
                quantity: 1,
                unit: "ks",
                pieces: 1,
                expiryDate: estimatedExpiry,
                category: item.category,
                status: .active,
                actionDate: Date()
            )
            
            state.products.append(newItem)
            
            do {
                try db.collection("kitchen")
                    .document(newId)
                    .setData(from: newItem)
                
                print("OCR item '\(item.name)' saved successfully.")
            } catch {
                print("Error saving item to Firestore: \(error)")
            }
        }
        
    }
    
    func updateItem(_ item: KitchenItem) {
        guard let id = item.id else { return }
        
        do {
            try db.collection("kitchen").document(id).setData(from: item, merge: true)
            
            if let index = state.products.firstIndex(where: { $0.id == id }) {
                state.products[index] = item
            }
            print("Polozka aktualizovana: \(item.name)")
        } catch {
            print("Chyba pri aktualizaci: \(error)")
            state.errorMessage = "Failed to update item"
        }
    }
}
