import Foundation
import FirebaseAuth
import FirebaseFirestore
import Observation

@Observable
class ProfileViewModel {
    var state = ProfileViewState()
    private var db = Firestore.firestore()
    

    
    func togglePreference(_ title: String) {
        if state.selectedPreferences.contains(title) {
            state.selectedPreferences.remove(title)
        } else {
            state.selectedPreferences.insert(title)
        }
        savePreferences()
    }
    
    func toggleRestriction(_ title: String) {
        if state.selectedRestrictions.contains(title) {
            state.selectedRestrictions.remove(title)
        } else {
            state.selectedRestrictions.insert(title)
        }
        saveRestrictions()
    }
    
    func fetchUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        

        state.userName = user.displayName ?? "No Name"
        state.members = [user] // Initialize list immediately
        

        user.reload { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error reloading user: \(error.localizedDescription)")
            }
            
            if let updatedUser = Auth.auth().currentUser {
                DispatchQueue.main.async {
                    self.state.userName = updatedUser.displayName ?? "No Name"
                    self.state.userAvatar = updatedUser.photoURL?.absoluteString ?? "person.crop.circle.fill"
                    
                    self.state.members = [updatedUser]
                }
            }
            
     
            let docRef = self.db.collection("users").document(user.uid)
            
            docRef.getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let document = snapshot, document.exists, let data = document.data() {
                    if let savedPrefs = data["dietaryPreferences"] as? [String] {
                        DispatchQueue.main.async {
                            print("Loaded Preferences: \(savedPrefs)")
                            self.state.selectedPreferences = Set(savedPrefs)
                        }
                    }
                }
            }
            
            docRef.getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let document = snapshot, document.exists, let data = document.data() {
                    if let savedRestr = data["dietaryRestrictons"] as? [String] {
                        DispatchQueue.main.async {
                            print("Loaded Restrictions: \(savedRestr)")
                            self.state.selectedRestrictions = Set(savedRestr)
                        }
                    }
                }
            }
        }
    }
    
    func savePreferences() {
        guard let user = Auth.auth().currentUser else { return }
        
        let dataToSave = Array(state.selectedPreferences)
        
        db.collection("users").document(user.uid).setData([
            "dietaryPreferences": dataToSave
        ], merge: true)
        
        NotificationCenter.default.post(name: .dietaryProfileChanged, object: nil)
        print("Saved to users, Preferences: \(dataToSave)")
    }
    
    func saveRestrictions() {
        guard let user = Auth.auth().currentUser else { return }
        
        let dataToSave = Array(state.selectedRestrictions)
        
        db.collection("users").document(user.uid).setData([
            "dietaryRestrictons": dataToSave
        ], merge: true)
        
        NotificationCenter.default.post(name: .dietaryProfileChanged, object: nil)
        print("Saved to users, Restricitons: \(dataToSave)")
    }
    
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            state.isLoggedOut = true
        } catch let signOutError as NSError {
            state.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
        }
    }
    

        func fetchDietaryProfileForAI() async -> (preferences: [String], restrictions: [String]) {
            guard let user = Auth.auth().currentUser else {
                return ([], [])
            }
            
            let db = Firestore.firestore()
            
            do {
                let snapshot = try await db.collection("users").document(user.uid).getDocument()
                
                guard let data = snapshot.data() else { return ([], []) }
                
           
                let prefs = data["dietaryPreferences"] as? [String] ?? []
                
               
                let restrs = data["dietaryRestrictons"] as? [String] ?? []
                
                return (prefs, restrs)
                
            } catch {
                print("Error fetching dietary profile: \(error)")
                return ([], [])     
            }
    }
}
extension Notification.Name {
    static let dietaryProfileChanged = Notification.Name("dietaryProfileChanged")
}
