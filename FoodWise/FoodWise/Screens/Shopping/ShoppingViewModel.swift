//
//  ShoppingListViewState 2.swift
//  FoodWise
//
//  Created by Illia Melnyk on 22.12.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine


class ShoppingViewModel: ObservableObject {
    
    @Published var state = ShoppingListViewState()
    private let watchConnector = WatchConnector.shared
    
    private var db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    
    func stopListening() {
        listeners.forEach { listener in
            listener.remove()
        }
        listeners.removeAll()
    }
    
    
    func fetchShoppingLists() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        stopListening()
        
        state.isLoading = true
        
        let listener = db.collection("shopping_lists")
            .whereField("members", arrayContains: currentUserId)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.state.isLoading = false
                    
                    if let error = error {
                        self.state.errorMessage = "Error: \(error.localizedDescription)"
                        return
                    }
                    
                    self.state.shoppingLists = snapshot?.documents.compactMap {
                        try? $0.data(as: ShoppingList.self)
                    } ?? []
                    
                    self.watchConnector.sendShoppingData(
                                        lists: self.state.shoppingLists,
                                        items: self.state.currentItems
                                    )
                }
            }
        listeners.append(listener)
    }
    
    func addShoppingList(name: String, date: Date) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let code = String(UUID().uuidString.prefix(6)).uppercased()
        
        let newList = ShoppingList(
            name: name,
            date: date,
            ownerId: currentUserId,
            members: [currentUserId],
            inviteCode: code
        )
        
        try? db.collection("shopping_lists").addDocument(from: newList)
    }
    
    func joinShoppingList(code: String) async -> Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
        
        do {
            let snapshot = try await db.collection("shopping_lists")
                .whereField("inviteCode", isEqualTo: code.uppercased())
                .getDocuments()
            
            guard let document = snapshot.documents.first else { return false }
            let listId = document.documentID
            
            try await db.collection("shopping_lists").document(listId).updateData([
                "members": FieldValue.arrayUnion([currentUserId])
            ])
            
            return true
        } catch {
            print("Chyba: \(error)")
            return false
        }
    }
    
    func deleteList(list: ShoppingList) {
        guard let id = list.id else { return }
        db.collection("shopping_lists").document(id).delete()
    }
    
    func fetchItems(for listId: String) {
        stopListening()
        
        let listener = db.collection("shopping_items")
            .whereField("listId", isEqualTo: listId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("Chyba položek: \(error)")
                        return
                    }
                    
                    self.state.currentItems = snapshot?.documents.compactMap {
                        try? $0.data(as: ShoppingItem.self)
                    } ?? []
                    
                    self.watchConnector.sendShoppingData(
                                        lists: self.state.shoppingLists,
                                        items: self.state.currentItems
                                    )
                }
            }
        listeners.append(listener)
    }
    
    func addItem(listId: String, name: String, quantity: String) {
        let newItem = ShoppingItem(
            id: UUID().uuidString,
            listId: listId,
            name: name,
            quantity: quantity,
            isCompleted: false
        )
        state.currentItems.append(newItem)
    
        
        do {
            let _ = try db.collection("shopping_items").addDocument(from: newItem)
        } catch {
            print("Chyba při přidávání položky: \(error)")
        }
    }
    
    func toggleItemCompletion(item: ShoppingItem) {
            guard let id = item.id else { return }
            
            if let index = state.currentItems.firstIndex(where: { $0.id == id }) {
                state.currentItems[index].isCompleted.toggle()
            
            }
            
            db.collection("shopping_items").document(id).updateData([
                "isCompleted": !item.isCompleted
            ]) { error in
                if let error = error {
                    print("Chyba při ukládání: \(error)")
                }
            }
    }
    
        func addIngredientsFromRecipeToDefaultList(ingredients: [IngredientItem]) {
            var targetListId = state.shoppingLists.first(where: { $0.name == "My List" })?.id
            
            if targetListId == nil {
                print("Seznam 'My List' nenalezen, vytvářím ho...")
                
                guard let currentUserId = Auth.auth().currentUser?.uid else { return }
                
                let newDocRef = db.collection("shopping_lists").document()
                let newListId = newDocRef.documentID
                let code = String(UUID().uuidString.prefix(6)).uppercased()
                
                let newList = ShoppingList(
                    id: newListId,
                    name: "My List",
                    date: Date(),
                    ownerId: currentUserId,
                    members: [currentUserId],
                    inviteCode: code
                )
                
                do {
                    try newDocRef.setData(from: newList)
                    targetListId = newListId
                } catch {
                    print("Chyba při vytváření 'My List': \(error)")
                    return
                }
            }
            
            guard let listId = targetListId else { return }
            
            let batch = db.batch()
            
            for ingredient in ingredients {
                let newItemRef = db.collection("shopping_items").document()
                let newItem = ShoppingItem(
                    listId: listId,
                    name: ingredient.name,
                    quantity: ingredient.quantity,
                    isCompleted: false
                )
                try? batch.setData(from: newItem, forDocument: newItemRef)
            }
            
            batch.commit { error in
                if let error = error {
                    print("Chyba: \(error)")
                } else {
                    print("Hotovo. Ingredience jsou v 'My List'.")
                }
            }
        }
}
