//
//  ProductListViewModel.swift
//  Task2Click
//
//  Created by Akbar Khusanbaev on 11/12/25.
//

import SwiftUI
import Combine

@MainActor
final class ProductListViewModel: ObservableObject {
    private let productService: ProductServicing

    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: LocalizedStringKey?

    init(productService: ProductServicing) {
        self.productService = productService
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            products = try await productService.fetchProducts()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load products. Please try again."
            products = []
        }

        isLoading = false
    }
}
