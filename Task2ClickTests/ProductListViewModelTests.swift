//
//  ProductListViewModelTests.swift
//  Task2ClickTests
//
//  Created by Akbar Khusanbaev on 11/12/25.
//

import XCTest
@testable import Task2Click

@MainActor
final class ProductListViewModelTests: XCTestCase {

    func testLoadProductsSuccess() async {
        let mockProducts = [
            Product(id: 1, title: "Test A", price: 10.0, description: "A", image: URL(string: "https://example.com/a.png")!),
            Product(id: 2, title: "Test B", price: 20.0, description: "B", image: URL(string: "https://example.com/b.png")!)
        ]
        let service = MockProductService(result: .success(mockProducts))
        let viewModel = ProductListViewModel(productService: service)

        await viewModel.loadProducts()

        XCTAssertFalse(viewModel.isLoading, "Loading flag should be false after fetch completes")
        XCTAssertNil(viewModel.errorMessage, "No error should be set on success")
        XCTAssertEqual(viewModel.products, mockProducts, "Products should match fetched data")
    }

    func testLoadProductsFailure() async {
        let service = MockProductService(result: .failure(URLError(.badServerResponse)))
        let viewModel = ProductListViewModel(productService: service)

        await viewModel.loadProducts()

        XCTAssertFalse(viewModel.isLoading, "Loading flag should be false after fetch completes")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set on failure")
        XCTAssertTrue(viewModel.products.isEmpty, "Products should be cleared on failure")
    }
}

private struct MockProductService: ProductServicing {
    let result: Result<[Product], Error>

    func fetchProducts() async throws -> [Product] {
        switch result {
        case .success(let products):
            return products
        case .failure(let error):
            throw error
        }
    }
}

