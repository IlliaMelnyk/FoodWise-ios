//
//  KitchenHouseholdService.swift
//  FoodWise
//
//  Created by Illia Melnyk on 23.12.2025.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class KitchenHouseholdService: ObservableObject {
    @Published var inviteCode: String = "Loading..."
    @Published var members: [UserProfile] = []
    
    static let shared = KitchenHouseholdService()
    @Published var currentHouseholdId: String?
    private var db = Firestore.firestore()
    
    func initializeHousehold() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let userDoc = try await db.collection("users").document(userId).getDocument()
            
            if let existingHouseholdId = userDoc.data()?["householdId"] as? String {
                DispatchQueue.main.async { self.currentHouseholdId = existingHouseholdId }
                await fetchHouseholdDetails(householdId: existingHouseholdId)
            } else {
                await createNewHousehold(ownerId: userId)
            }
        } catch {
            print("Error initializing household: \(error)")
        }
    }
    
    private func createNewHousehold(ownerId: String) async {
            let newHouseholdId = UUID().uuidString
            let code = String(UUID().uuidString.prefix(6)).uppercased()
            let currentUser = Auth.auth().currentUser
            
            let householdData: [String: Any] = [
                "ownerId": ownerId,
                "members": [ownerId],
                "inviteCode": code,
                "createdAt": Date()
            ]
            
            do {
                try await db.collection("households").document(newHouseholdId).setData(householdData)
                
                let userData: [String: Any] = [
                    "householdId": newHouseholdId,
                    "uid": ownerId,
                    "email": currentUser?.email ?? "",
                    "name": currentUser?.displayName ?? "Unknown User",
                    "avatarImage": "person.crop.circle.fill"
                ]
                
                try await db.collection("users").document(ownerId).setData(userData, merge: true)
                
                DispatchQueue.main.async {
                    self.currentHouseholdId = newHouseholdId
                    self.inviteCode = code
                }
                await fetchHouseholdDetails(householdId: newHouseholdId)
            } catch {
                print("Failed to create household: \(error)")
            }
    }
    
    func fetchHouseholdDetails(householdId: String) async {
        do {
            let doc = try await db.collection("households").document(householdId).getDocument()
            if let data = doc.data() {
                DispatchQueue.main.async {
                    self.inviteCode = data["inviteCode"] as? String ?? "N/A"
                }
                
                if let memberIds = data["members"] as? [String] {
                    await fetchMemberProfiles(ids: memberIds)
                }
            }
        } catch {
            print("Error fetching details: \(error)")
        }
    }
    
    private func fetchMemberProfiles(ids: [String]) async {
        var loadedMembers: [UserProfile] = []
        
        for id in ids {
            if let doc = try? await db.collection("users").document(id).getDocument(),
               let user = try? doc.data(as: UserProfile.self) {
                loadedMembers.append(user)
            }
        }
        
        DispatchQueue.main.async {
            self.members = loadedMembers
        }
    }
    
    func joinHousehold(code: String) async -> Bool {
            guard let userId = Auth.auth().currentUser?.uid else { return false }
            
            do {
                let oldUserDoc = try await db.collection("users").document(userId).getDocument()
                let oldHouseholdId = oldUserDoc.data()?["householdId"] as? String
                
                let query = try await db.collection("households").whereField("inviteCode", isEqualTo: code).getDocuments()
                guard let doc = query.documents.first else { return false }
                let newHouseholdId = doc.documentID
                
                if oldHouseholdId == newHouseholdId { return true }
                
                if let oldId = oldHouseholdId {
                    await migrateKitchenItems(from: oldId, to: newHouseholdId)
                }
                
                try await db.collection("users").document(userId).updateData(["householdId": newHouseholdId])
                try await db.collection("households").document(newHouseholdId).updateData([
                    "members": FieldValue.arrayUnion([userId])
                ])
                
                await initializeHousehold()
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("HouseholdChanged"), object: nil)
                }
                
                return true
            } catch {
                print("Join failed: \(error)")
                return false
            }
        }
        
        private func migrateKitchenItems(from oldId: String, to newId: String) async {
            do {
                let items = try await db.collection("kitchen").whereField("householdId", isEqualTo: oldId).getDocuments()
                
                let batch = db.batch()
                
                for doc in items.documents {
                    let ref = db.collection("kitchen").document(doc.documentID)
                    batch.updateData(["householdId": newId], forDocument: ref)
                }
                
                try await batch.commit()
                print("Migrace úspěšná: \(items.count) položek přesunuto.")
            } catch {
                print("Chyba při migraci položek: \(error)")
            }
        }
    func leaveCurrentHousehold() async -> Bool {
            guard let user = Auth.auth().currentUser else { return false }
            guard let oldHouseholdId = currentHouseholdId else { return false }
            
            do {
                // 1. Odstraníme uživatele ze STARÉ kuchyně v DB
                try await db.collection("households").document(oldHouseholdId).updateData([
                    "members": FieldValue.arrayRemove([user.uid])
                ])
                
                // 2. Připravíme data pro NOVOU kuchyni
                let newHouseholdId = UUID().uuidString
                let newCode = String(UUID().uuidString.prefix(6)).uppercased()
                
                let newHouseholdData: [String: Any] = [
                    "id": newHouseholdId,
                    "ownerId": user.uid,
                    "members": [user.uid],
                    "inviteCode": newCode,
                    "createdAt": Date()
                ]
                
                // 3. Vytvoříme NOVOU kuchyni v DB
                try await db.collection("households").document(newHouseholdId).setData(newHouseholdData)
                
                // 4. Přepneme uživatele v DB do nové kuchyně
                try await db.collection("users").document(user.uid).updateData([
                    "householdId": newHouseholdId
                ])
                
                // 5. TEĎ aktualizujeme lokální data (čekáme na dokončení!)
                // Nejdřív si načteme profil uživatele (protože jsme ho právě updatovali)
                // nebo prostě jen zavoláme fetchMemberProfiles pro aktuální UID.
                
                await MainActor.run {
                    self.currentHouseholdId = newHouseholdId
                    self.inviteCode = newCode
                    // Vyčistíme staré členy, aby tam neviseli
                    self.members = []
                }
                
                // 6. Načteme profil "nového" člena (sebe) DO PŘEDTÍM, než vrátíme true
                // Díky tomu zmizí "Loading"
                await fetchMemberProfiles(ids: [user.uid])
                
                // 7. Notifikace pro ostatní části aplikace
                await MainActor.run {
                    NotificationCenter.default.post(name: NSNotification.Name("HouseholdChanged"), object: nil)
                }
                
                return true
                
            } catch {
                print("Error leaving household: \(error)")
                return false
            }
        }
}
