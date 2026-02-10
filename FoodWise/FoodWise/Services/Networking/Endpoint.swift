//
//  Endpoint.swift
//  FoodWise
//
//  Created by Artsiom Halachkin on 16.12.2025.
//

import Foundation

protocol Endpoint {
    var host: String { get }
    var path: String { get }
    var method: HttpMethod { get }
    var headers: [String: String] { get }
    var urlParameters: [String: Any]? { get }
    var body: Data? { get }

    func asRequest() throws -> URLRequest
}

extension Endpoint {
    func asRequest() throws -> URLRequest {
        var components = URLComponents()
        let cleanHost = host.replacingOccurrences(of: "https://", with: "")
        components.scheme = "https"
        components.host = cleanHost
        components.path = path

        if let params = urlParameters {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }

        guard let url = components.url else {
            throw NSError(domain: "InvalidURL", code: 0)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        if method != .get {
            request.httpBody = body
        }

        return request
    }
}
