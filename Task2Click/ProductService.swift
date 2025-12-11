//
//  ProductService.swift
//  Task2Click
//
//  Created by Akbar Khusanbaev on 11/12/25.
//

import Foundation

protocol ProductServicing {
    func fetchProducts() async throws -> [Product]
}

struct FakeStoreProductService: ProductServicing {
    private let session: URLSession
    private let baseURL = URL(string: "https://fakestoreapi.com")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProducts() async throws -> [Product] {
        let request = URLRequest(url: baseURL.appending(path: "products"))
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Product].self, from: data)
    }
}
