//
//  GoogleAIStudioService.swift
//  FoodWise
//
//  Created by Illia Melnyk on 18.12.2025.
//

import Foundation

import Foundation

struct WasteGroup: Decodable, Identifiable {
    let id = UUID()
    let categoryName: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case categoryName = "kategorie"
        case count = "pocet"
    }
}

struct GeminiWasteResponse: Decodable {
    let groups: [WasteGroup]
}

struct AIReceiptItem: Decodable {
    let name: String
    let days: Int
    let category: String

}


final class GoogleAIStudioService {
    
    func fetchCategorizedRecipes(
        allIngredients: [String],
        expiringIngredients: [String],
        preferences: [String],
        restrictions: [String]
    ) async throws -> GeminiRecipeResponse {
        
        let router = GoogleAIStudioRouter.generateCategorizedRecipes(
            allIngredients: allIngredients,
            expiringIngredients: expiringIngredients,
            preferences: preferences,
            restrictions: restrictions
        )

        let request = try router.asRequest()
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try validateResponse(response: response, data: data)

        let rawText = try extractTextFromGemini(data: data)
        let jsonData = try cleanJsonString(rawText)
        
        do {
            return try JSONDecoder().decode(GeminiRecipeResponse.self, from: jsonData)
        } catch {
            print("Error parsing recipes: \(error)")
            throw error
        }
    }
    
    func analyzeWaste(items: [String]) async throws -> [WasteGroup] {
        if items.isEmpty { return [] }
        
        let router = GoogleAIStudioRouter.analyzeWaste(items: items)
        let request = try router.asRequest()
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try validateResponse(response: response, data: data)
        
        let rawText = try extractTextFromGemini(data: data)
        let jsonData = try cleanJsonString(rawText)
        
        do {
            let result = try JSONDecoder().decode(GeminiWasteResponse.self, from: jsonData)
            return result.groups
        } catch {
            print("Error parsing waste stats: \(error)")
            throw error
        }
    }
    
    func parseReceipt(text: String) async throws -> [AIReceiptItem] {
        let router = GoogleAIStudioRouter.parseReceipt(rawText: text)
        let request = try router.asRequest()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try validateResponse(response: response, data: data)
        
        let rawText = try extractTextFromGemini(data: data)
        print("A RAW RESPONSE: \(rawText)")
        let jsonData = try cleanJsonString(rawText)
        
        do {
            return try JSONDecoder().decode([AIReceiptItem].self, from: jsonData)
        } catch {
            print("Error parsing receipt items: \(error)")
            throw error
        }
    }
    
    private func validateResponse(response: URLResponse, data: Data) throws {
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "No body"
            throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: ["body": body])
        }
    }
    
    private func extractTextFromGemini(data: Data) throws -> String {
        struct GeminiOuterResponse: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable { let text: String }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]?
        }
        
        let outer = try JSONDecoder().decode(GeminiOuterResponse.self, from: data)
        guard let text = outer.candidates?.first?.content.parts.first?.text else {
            throw NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "Gemini returned no text."])
        }
        return text
    }
    
    private func cleanJsonString(_ raw: String) throws -> Data {
        let clean = raw.replacingOccurrences(of: "```json", with: "")
                       .replacingOccurrences(of: "```", with: "")
                       .trimmingCharacters(in: .whitespacesAndNewlines)
       
        guard let data = clean.data(using: .utf8) else {
            throw NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to data."])
        }
        return data
    }
}
