//
//  ImageCache.swift
//  Task2Click
//
//  Created by Akbar Khusanbaev on 11/12/25.
//

import UIKit

final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    subscript(url: NSURL) -> UIImage? {
        get { cache.object(forKey: url) }
        set {
            if let newValue = newValue {
                cache.setObject(newValue, forKey: url)
            } else {
                cache.removeObject(forKey: url)
            }
        }
    }
}
