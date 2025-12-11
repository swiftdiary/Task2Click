//
//  ContentView.swift
//  Task2Click
//
//  Created by Akbar Khusanbaev on 11/12/25.
//

import SwiftUI

@MainActor
struct ProductsView: View {
    @StateObject private var viewModel: ProductListViewModel

    init() {
        _viewModel = StateObject(wrappedValue: ProductListViewModel(productService: FakeStoreProductService()))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                content
                if viewModel.isLoading {
                    ProgressView("Loading products...")
                        .padding(16)
                        .padding(.horizontal, 8)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .navigationTitle("Products Store")
        }
        .task {
            await viewModel.loadProducts()
        }
        .refreshable {
            await viewModel.loadProducts()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.products.isEmpty, let message = viewModel.errorMessage {
            VStack(spacing: 12) {
                Text("Oops!")
                    .font(.title2.weight(.semibold))
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button("Retry") {
                    Task { await viewModel.loadProducts() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        } else {
            List(viewModel.products) { product in
                ProductRow(product: product)
            }
            .listStyle(.plain)
        }
    }
}

private struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CachedAsyncImage(url: product.image) {
                ProgressView()
            }
            .frame(width: 64, height: 64)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(product.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(product.price, format: .currency(code: "USD"))
                    .font(.subheadline.weight(.semibold))
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProductsView()
}
