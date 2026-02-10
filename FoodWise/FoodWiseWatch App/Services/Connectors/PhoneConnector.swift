//
//  PhoneConnector.swift
//  FoodWiseWatch Watch App
//
//  Created by Illia Melnyk on 02.01.2026.
//

import Foundation
import WatchConnectivity
import Combine
import WatchKit

class PhoneConnector: NSObject, WCSessionDelegate, ObservableObject {
    
    private var session: WCSession
    
    @Published var receivedKitchenItems: [KitchenItem] = []
    @Published var receivedShoppingLists: [ShoppingList] = []
    @Published var receivedShoppingItems: [ShoppingItem] = []
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        
        loadFromCache()
        
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch: Session activated")
        requestDataFromPhone()
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.processData(context: applicationContext)
        }
    }
    
    private func processData(context: [String: Any]) {
        var dataChanged = false
        
        if let kitchenData = context["kitchenData"] as? Data {
            if let items = try? JSONDecoder().decode([KitchenItem].self, from: kitchenData) {
                self.receivedKitchenItems = items
                dataChanged = true
            }
        }
        
        if let listsData = context["shoppingLists"] as? Data {
            if let lists = try? JSONDecoder().decode([ShoppingList].self, from: listsData) {
                if !lists.isEmpty {
                    self.receivedShoppingLists = lists
                    dataChanged = true
                }
            }
        }
        
        if let itemsData = context["shoppingItems"] as? Data {
            if let items = try? JSONDecoder().decode([ShoppingItem].self, from: itemsData) {
                self.receivedShoppingItems = items
                dataChanged = true
            }
        }
        
        if dataChanged {
            saveToCache()
            print("Watch: Data updated and cached")
        }
    }
    
    func consumeItem(_ item: KitchenItem) {
        removeItemLocally(item)
        sendAction(action: "consumeItem", itemId: item.id)
        WKInterfaceDevice.current().play(.success)
    }
    
    func wasteItem(_ item: KitchenItem) {
        removeItemLocally(item)
        sendAction(action: "wasteItem", itemId: item.id)
        WKInterfaceDevice.current().play(.directionDown)
    }
    
    private func removeItemLocally(_ item: KitchenItem) {
        if let index = receivedKitchenItems.firstIndex(where: { $0.id == item.id }) {
            receivedKitchenItems.remove(at: index)
            saveToCache()
        }
    }
    
    func toggleItem(_ item: ShoppingItem) {
        if let index = receivedShoppingItems.firstIndex(where: { $0.id == item.id }) {
            var newItem = receivedShoppingItems[index]
            newItem.isCompleted.toggle()
            receivedShoppingItems[index] = newItem
            WKInterfaceDevice.current().play(.click)
        }
        sendAction(action: "toggleItem", itemId: item.id)
    }
    
    func requestItems(for listId: String) {
        guard session.isReachable else { return }
        session.sendMessage(["action": "fetchListItems", "listId": listId], replyHandler: nil)
    }
    
    func requestDataFromPhone() {
        guard session.isReachable else { return }
        session.sendMessage(["action": "refreshAllData"], replyHandler: nil)
    }
    
    private func sendAction(action: String, itemId: String?) {
        guard session.isReachable, let id = itemId else { return }
        session.sendMessage(["action": action, "itemId": id], replyHandler: nil)
    }
    
    private func saveToCache() {
        if let encodedKitchen = try? JSONEncoder().encode(receivedKitchenItems) {
            UserDefaults.standard.set(encodedKitchen, forKey: "cached_kitchen")
        }
        if let encodedLists = try? JSONEncoder().encode(receivedShoppingLists) {
            UserDefaults.standard.set(encodedLists, forKey: "cached_lists")
        }
        if let encodedItems = try? JSONEncoder().encode(receivedShoppingItems) {
            UserDefaults.standard.set(encodedItems, forKey: "cached_items")
        }
    }
    
    private func loadFromCache() {
        if let kitchenData = UserDefaults.standard.data(forKey: "cached_kitchen"),
           let items = try? JSONDecoder().decode([KitchenItem].self, from: kitchenData) {
            self.receivedKitchenItems = items
        }
        if let listsData = UserDefaults.standard.data(forKey: "cached_lists"),
           let lists = try? JSONDecoder().decode([ShoppingList].self, from: listsData) {
            self.receivedShoppingLists = lists
        }
        if let itemsData = UserDefaults.standard.data(forKey: "cached_items"),
           let items = try? JSONDecoder().decode([ShoppingItem].self, from: itemsData) {
            self.receivedShoppingItems = items
        }
    }
}
