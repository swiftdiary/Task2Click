//
//  CachedAsyncImage.swift
//  Task2Click
//
//  Created by Akbar Khusanbaev on 11/12/25.
//

import SwiftUI
import Combine

struct CachedAsyncImage<Placeholder: View>: View {
    private let url: URL?
    private let placeholder: Placeholder
    @StateObject private var loader: ImageLoader

    init(url: URL?, cache: ImageCache = .shared, @ViewBuilder placeholder: () -> Placeholder = { ProgressView() }) {
        self.url = url
        self.placeholder = placeholder()
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: cache))
    }

    var body: some View {
        content
            .task {
                await loader.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        if let image = loader.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if loader.isLoading {
            placeholder
        } else {
            placeholder
        }
    }
}

@MainActor
private final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading: Bool = false

    private let url: URL?
    private let cache: ImageCache
    private var task: Task<Void, Never>?

    init(url: URL?, cache: ImageCache) {
        self.url = url
        self.cache = cache
    }

    deinit {
        task?.cancel()
    }

    func load() async {
        guard !isLoading else { return }
        guard let url else { return }

        if let cached = cache[url as NSURL] {
            image = cached
            return
        }

        isLoading = true

        task = Task.detached(priority: .utility) { [weak self] in
            let result: UIImage?
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                result = UIImage(data: data)
            } catch {
                result = nil
            }

            await MainActor.run { [weak self] in
                guard let self else { return }
                self.isLoading = false
                if let result {
                    cache[url as NSURL] = result
                    self.image = result
                }
            }
        }

        await task?.value
    }
}
