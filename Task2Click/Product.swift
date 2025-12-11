//
//  Product.swift
//  Task2Click
//
//  Created by Akbar Khusanbaev on 11/12/25.
//

import Foundation

struct Product: Identifiable, Decodable, Equatable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let image: URL
}
