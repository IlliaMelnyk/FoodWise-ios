//
//  UnsplashRouter.swift
//  FoodWise
//
//  Created by Illia Melnyk on 18.12.2025.
//


import Foundation

enum UnsplashRouter: Endpoint {
    case searchPhoto(query: String)

    var host: String { "api.unsplash.com" }
    var path: String { "/search/photos" }
    var method: HttpMethod { .get }
    
    var headers: [String: String] {
        guard let clientId = Secrets.get("UNSPLASH_API_KEY") else { return [:] }
        return [
            "Authorization": "Client-ID \(clientId)",
            "Accept-Version": "v1"
        ]
    }

    var urlParameters: [String: Any]? {
        switch self {
        case let .searchPhoto(query):
            return ["query": query, "per_page": 1, "orientation": "squarish"]
        }
    }
    
    var body: Data? { nil }
}
