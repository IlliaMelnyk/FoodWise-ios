//
//  WatchConnector.swift
//  FoodWise
//
//  Created by Illia Melnyk on 02.01.2026.
//

import Foundation
import WatchConnectivity
import FirebaseFirestore
import FirebaseAuth
import Combine

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = WatchConnector()
    
    private var session: WCSession
    private let db = Firestore.firestore()
    
    private var pendingKitchenData: [KitchenItem]?
    private var pendingShoppingLists: [ShoppingList]?
    private var pendingShoppingItems: [ShoppingItem]?
    
    private override init() {
        self.session = .default
        super.init()
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iOS: WCSession activation completed. State: \(activationState.rawValue)")
        if activationState == .activated {
            sendPendingData()
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("iOS: Received message: \(message)")
        
        guard let action = message["action"] as? String else { return }
        
        if action == "consumeItem", let itemId = message["itemId"] as? String {
            updateKitchenItemStatus(itemId: itemId, status: "used")
        }
        
        if action == "wasteItem", let itemId = message["itemId"] as? String {
            updateKitchenItemStatus(itemId: itemId, status: "wasted")
        }
        
        if action == "toggleItem", let itemId = message["itemId"] as? String {
            toggleShoppingItem(itemId: itemId)
        }
        
        if action == "fetchListItems", let listId = message["listId"] as? String {
             fetchItemsOnlyAndSend(listId: listId)
        }
        
        if action == "refreshAllData" {
            print("iOS: Watch requested refresh. Fetching data...")
            fetchAllDataAndSend()
        }
    }
    
    private func updateKitchenItemStatus(itemId: String, status: String) {
        let docRef = db.collection("kitchen").document(itemId)
        docRef.updateData([
            "status": status,
            "actionDate": Date()
        ]) { error in
            if let error = error {
                print("iOS: Error updating kitchen item: \(error)")
            } else {
                print("iOS: Kitchen item \(itemId) status set to \(status)")
            }
        }
    }
    
    private func toggleShoppingItem(itemId: String) {
        let docRef = db.collection("shopping_items").document(itemId)
        docRef.getDocument { document, _ in
            if let document = document, document.exists {
                let currentStatus = document.data()?["isCompleted"] as? Bool ?? false
                docRef.updateData(["isCompleted": !currentStatus])
            }
        }
    }
    
    private func fetchAllDataAndSend() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        if let memoryHouseholdId = KitchenHouseholdService.shared.currentHouseholdId {
            fetchKitchenItemsAndSend(householdId: memoryHouseholdId)
        } else {
            db.collection("households")
                .whereField("members", arrayContains: currentUserId)
                .limit(to: 1)
                .getDocuments { [weak self] snapshot, _ in
                    guard let self = self, let doc = snapshot?.documents.first else { return }
                    self.fetchKitchenItemsAndSend(householdId: doc.documentID)
                }
        }
        
        db.collection("shopping_lists")
            .whereField("members", arrayContains: currentUserId)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, _ in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                let lists = documents.compactMap { try? $0.data(as: ShoppingList.self) }
                self.sendShoppingData(lists: lists, items: [])
            }
    }
    
    private func fetchKitchenItemsAndSend(householdId: String) {
        db.collection("kitchen")
            .whereField("householdId", isEqualTo: householdId)
            .whereField("status", isEqualTo: "active")
            .getDocuments { [weak self] snapshot, _ in
                guard let self = self, let docs = snapshot?.documents else { return }
                let items = docs.compactMap { try? $0.data(as: KitchenItem.self) }
                self.sendKitchenData(items: items)
            }
    }
    
    private func fetchItemsOnlyAndSend(listId: String) {
        db.collection("shopping_items")
            .whereField("listId", isEqualTo: listId)
            .getDocuments { [weak self] snapshot, _ in
                guard let self = self, let documents = snapshot?.documents else { return }
                let items = documents.compactMap { try? $0.data(as: ShoppingItem.self) }
                self.sendShoppingData(lists: [], items: items)
            }
    }
    
    private func sendPendingData() {
        if let kitchen = pendingKitchenData { sendKitchenData(items: kitchen) }
        if let lists = pendingShoppingLists, let items = pendingShoppingItems { sendShoppingData(lists: lists, items: items) }
    }
    
    func sendKitchenData(items: [KitchenItem]) {
        guard session.activationState == .activated else {
            self.pendingKitchenData = items
            return
        }
        
        let payload = items.map { item in
            KitchenItemPayload(
                id: item.id,
                householdId: item.householdId,
                name: item.name,
                quantity: item.quantity,
                unit: item.unit,
                pieces: item.pieces,
                expiryDate: item.expiryDate,
                category: item.category,
                statusRawValue: item.status?.rawValue
            )
        }
        
        do {
            let data = try JSONEncoder().encode(payload)
            try session.updateApplicationContext(["kitchenData": data])
            self.pendingKitchenData = nil
            print("iOS: Kitchen data sent")
        } catch {
            print("iOS: Error sending kitchen data: \(error)")
        }
    }
        
    func sendShoppingData(lists: [ShoppingList], items: [ShoppingItem]) {
        guard session.activationState == .activated else {
            self.pendingShoppingLists = lists
            self.pendingShoppingItems = items
            return
        }
        
        let listsPayload = lists.map { list in
            ShoppingListPayload(
                id: list.id,
                name: list.name,
                date: list.date,
                ownerId: list.ownerId,
                members: list.members,
                inviteCode: list.inviteCode
            )
        }
        
        let itemsPayload = items.map { item in
            ShoppingItemPayload(
                id: item.id,
                listId: item.listId,
                name: item.name,
                quantity: item.quantity,
                isCompleted: item.isCompleted
            )
        }
        
        do {
            let listsData = try JSONEncoder().encode(listsPayload)
            let itemsData = try JSONEncoder().encode(itemsPayload)
            
            var context = session.applicationContext
            context["shoppingLists"] = listsData
            context["shoppingItems"] = itemsData
            
            try session.updateApplicationContext(context)
            self.pendingShoppingLists = nil
            self.pendingShoppingItems = nil
            print("iOS: Shopping data sent")
        } catch {
            print("iOS: Error sending shopping data: \(error)")
        }
    }
}
