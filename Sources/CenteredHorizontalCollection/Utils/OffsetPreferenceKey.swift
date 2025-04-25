//
//  OffsetPreferenceKey.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/25/25.
//


import SwiftUI

/// Preference key to track offsets of items in a ScrollView
struct OffsetPreferenceKey: PreferenceKey {
	// Using a computed property to avoid shared mutable state
	static var defaultValue: [Int: CGFloat] { [:] }
	
	static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
		value.merge(nextValue()) { (_, new) in new }
	}
}
