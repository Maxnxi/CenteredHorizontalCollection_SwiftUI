//
//  ItemView.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/25/25.
//


import SwiftUI

/// Reusable view for each item in the collection
public struct ItemView: View {
    let item: Item
    let isSelected: Bool
    let onTap: () -> Void
    
    /// Creates a new item view
    /// - Parameters:
    ///   - item: The data model for this item
    ///   - isSelected: Whether this item is currently selected
    ///   - onTap: Closure to call when this item is tapped
    public init(
        item: Item,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) {
        self.item = item
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(item.color)
            .frame(
                width: HorizontalCollectionConstants.itemSize,
                height: HorizontalCollectionConstants.itemSize
            )
            .overlay(
                Text("\(item.id)")
                    .font(.caption)
                    .foregroundColor(.white)
            )
            .shadow(radius: isSelected ? 6 : 2)
            .scaleEffect(isSelected ? 1.1 : 0.9)
            .onTapGesture {
                DebugUtility.debugPrint(.interaction, "Item \(item.id) tapped")
                onTap()
            }
    }
}