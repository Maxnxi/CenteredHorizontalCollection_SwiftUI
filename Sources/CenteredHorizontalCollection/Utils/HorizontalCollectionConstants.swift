//
//  HorizontalCollectionConstants.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/25/25.
//

import Foundation
import SwiftUI

/// Constants used across the collection view implementation
/// Thread-safe configuration through actor isolation
public actor HorizontalCollectionConstants {
	// UI layout constants
	public static var itemSize: CGFloat = 56
	public static var itemSpacing: CGFloat = 16
	
	// Animation constants - adjusted for more natural feel
	public static var selectionAnimationDuration: Double = 0.25
	public static var selectionAnimationDuringDrag: Double = 0.1
	public static var scrollDebounceTime: Double = 0.1
	
	// Real-time selection behavior during drag
	public static var enableRealTimeSelection: Bool = true
	public static var realTimeSelectionThreshold: CGFloat = 30
	
	// Force center on selection
	public static var alwaysCenterSelectedItem: Bool = true
	
	// Debug settings
	public static var debugMode: Bool = false
	
	// Correction constants
	public static var minCorrectionThreshold: CGFloat = 2.0
	public static var maxCorrectionThreshold: CGFloat = 40.0
	
	// Current scroll behavior mode
	public static var scrollBehaviorMode: ScrollBehaviorMode = .standard
	
	// Scroll snapping behavior settings
	public static var useSnappingBehavior: Bool = true
	public static var scrollSnapSensitivity: CGFloat = 0.7
	
	// Advanced scrolling parameters (used in targetContentOffset mode)
	public static var velocityMultiplier: CGFloat = 0.25
	public static var snapStrength: CGFloat = 0.75
	public static var maxItemsToAdvance: Int = 50
	
	// Velocity thresholds for natural scrolling behavior with support for fast scrolling
	public static var lowVelocityThreshold: CGFloat = 40.0
	public static var mediumVelocityThreshold: CGFloat = 200.0
	public static var highVelocityMultiplier: CGFloat = 0.012
	
	// Screen dimensions helper - marked nonisolated for sync access
	@MainActor
	public static var screenWidth: CGFloat {
		#if os(iOS)
		UIScreen.main.bounds.width
		#else
		1080 // Default for non-iOS platforms
		#endif
	}
	
	// Calculate corner spacer width to allow first and last items to center
	// This is a computed property that depends on mutable state, so it needs isolation
	@MainActor
	public static var cornerSpacerWidth: CGFloat {
		(screenWidth - itemSize) / 2
	}
	
	/// Configure the collection constants
	/// - Parameters:
	///   - itemSize: Size of each item
	///   - itemSpacing: Spacing between items
	///   - debugMode: Whether debug logging is enabled
	///   - scrollBehaviorMode: The scrolling behavior mode
	public static func configure(
		itemSize: CGFloat? = nil,
		itemSpacing: CGFloat? = nil,
		debugMode: Bool? = nil,
		scrollBehaviorMode: ScrollBehaviorMode? = nil
	) async {
		if let itemSize = itemSize {
			self.itemSize = itemSize
		}
		
		if let itemSpacing = itemSpacing {
			self.itemSpacing = itemSpacing
		}
		
		if let debugMode = debugMode {
			self.debugMode = debugMode
		}
		
		if let scrollBehaviorMode = scrollBehaviorMode {
			self.scrollBehaviorMode = scrollBehaviorMode
		}
	}
}
