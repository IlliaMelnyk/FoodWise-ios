import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore 

class RecipesViewModel: ObservableObject {
    
    @Published var readyToCook: [Recipe] = []
    @Published var expiringSoon: [Recipe] = []
    @Published var needMoreIngredients: [Recipe] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let unsplashService = UnsplashService()
    private let db = Firestore.firestore() // 1. Initialize Firestore
    
    func loadRecipes(from items: [KitchenItem]) {
        
        isLoading = true
        errorMessage = nil
        
        let allIngredientNames = items.map { $0.name }
        
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let expiringIngredientNames = items.filter { item in
            return item.expiryDate < nextWeek
        }.map { $0.name }
        
        print("ViewModel: Načítám recepty pro: \(allIngredientNames)")
        
        Task {
            do {
                let dietProfile = await fetchDietaryProfile()
                print("Dietary Profile Applied: \(dietProfile)")

                let response = try await fetchCategorizedRecipes(
                    all: allIngredientNames,
                    expiring: expiringIngredientNames,
                    preferences: dietProfile.preferences,
                    restrictions: dietProfile.restrictions
                )
                
                let ready = response.readyToCook
                let expiring = response.expiringSoon
                let needMore = response.needMoreIngredients
                
                async let readyWithImages = fetchImagesForList(recipes: ready)
                async let expiringWithImages = fetchImagesForList(recipes: expiring)
                async let needMoreWithImages = fetchImagesForList(recipes: needMore)
                
                let finalReady = await readyWithImages
                let finalExpiring = await expiringWithImages
                let finalNeedMore = await needMoreWithImages
                
                DispatchQueue.main.async { [weak self] in
                    print("Recepty úspěšně načteny.")
                    self?.readyToCook = finalReady
                    self?.expiringSoon = finalExpiring
                    self?.needMoreIngredients = finalNeedMore
                    self?.isLoading = false
                }
                
            } catch {
                print("Chyba při načítání receptů: \(error.localizedDescription)")
                
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = "Nepodařilo se vymyslet recepty. Zkuste to prosím později."
                    self?.isLoading = false
                }
            }
        }
    }
    
 
    private func fetchDietaryProfile() async -> (preferences: [String], restrictions: [String]) {
        guard let user = Auth.auth().currentUser else {
            return ([], [])
        }
        
        do {
            let snapshot = try await db.collection("users").document(user.uid).getDocument()
            guard let data = snapshot.data() else { return ([], []) }
            
            let prefs = data["dietaryPreferences"] as? [String] ?? []
            let restrs = data["dietaryRestrictons"] as? [String] ?? []
            
            return (prefs, restrs)
        } catch {
            print("Failed to fetch profile: \(error)")
            return ([], [])
        }
    }
    
   
    private func fetchImagesForList(recipes: [Recipe]) async -> [Recipe] {
        var updatedRecipes: [Recipe] = []
        
        for var recipe in recipes {
            do {
     
                let imageUrl = try await fetchUnsplashImage(query: recipe.imageKeywords)
                recipe.imageUrl = imageUrl
            } catch {
                print("Fotka pro '\(recipe.imageKeywords)' nenalezena.")
            }
            updatedRecipes.append(recipe)
        }
        return updatedRecipes
    }
    
    private func fetchUnsplashImage(query: String) async throws -> String? {
        return try await unsplashService.searchImageURL(query: query)
    }
    

    private func fetchCategorizedRecipes(
        all: [String],
        expiring: [String],
        preferences: [String],  // Added argument
        restrictions: [String]  // Added argument
    ) async throws -> GeminiRecipeResponse {
        
 
        let endpoint = GoogleAIStudioRouter.generateCategorizedRecipes(
            allIngredients: all,
            expiringIngredients: expiring,
            preferences: preferences,
            restrictions: restrictions
        )
        
        let request = try endpoint.asRequest()
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "ServerHTTPError", code: httpResponse.statusCode, userInfo: ["body": body])
        }
        
       
        struct GeminiOuter: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable { let text: String }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]?
        }
        
        let outer = try JSONDecoder().decode(GeminiOuter.self, from: data)
        
        guard let rawText = outer.candidates?.first?.content.parts.first?.text else {
            throw NSError(domain: "GeminiError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Prázdná odpověď od AI"])
        }
        
        let cleanJson = rawText.replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleanJson.data(using: .utf8) else {
            throw NSError(domain: "GeminiError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Chyba konverze stringu na data"])
        }
        
        return try JSONDecoder().decode(GeminiRecipeResponse.self, from: jsonData)
    }
}
