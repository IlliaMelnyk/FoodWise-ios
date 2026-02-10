//
//  Misc.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}



enum APIError: Error {
    case invalidHost
    case invalidURLComponents
    case noResponse
    case unacceptableResponseStatusCode
    case customDecodingFailed
}
