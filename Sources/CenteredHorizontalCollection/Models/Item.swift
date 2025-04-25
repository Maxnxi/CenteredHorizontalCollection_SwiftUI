//
//  Item.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/25/25.
//


import SwiftUI

/// Model for a demo collection item
public struct Item: Identifiable {
    public let id: Int
    public let color: Color
    
    /// Creates a new Item
    /// - Parameters:
    ///   - id: The unique identifier for this item
    ///   - color: The background color for this item
    public init(id: Int, color: Color) {
        self.id = id
        self.color = color
    }
}