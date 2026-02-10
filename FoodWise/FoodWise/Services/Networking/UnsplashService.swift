//
//  UnsplashService.swift
//  FoodWise
//
//  Created by Illia Melnyk on 18.12.2025.
//

import Foundation

final class UnsplashService {
    
    func searchImageURL(query: String) async throws -> String? {
        let endpoint = UnsplashRouter.searchPhoto(query: query)
        
        let request = try endpoint.asRequest()
        let (data, _) = try await URLSession.shared.data(for: request)
        
        struct UnsplashResponse: Decodable {
            struct Result: Decodable {
                struct Urls: Decodable {
                    let regular: String
                }
                let urls: Urls
            }
            let results: [Result]
        }
        
        let response = try JSONDecoder().decode(UnsplashResponse.self, from: data)
        return response.results.first?.urls.regular
    }
}
