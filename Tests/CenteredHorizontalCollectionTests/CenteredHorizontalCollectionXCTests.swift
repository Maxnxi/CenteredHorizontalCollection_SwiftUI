//
//  CenteredHorizontalCollectionTests.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/25/25.
//

import XCTest
import SwiftUI
@testable import CenteredHorizontalCollection

final class CenteredHorizontalCollectionTests: XCTestCase {
	func testItemInitialization() {
		// Test that Item initializes correctly
		let item = Item(id: 1, color: .red)
		XCTAssertEqual(item.id, 1)
		// We can't directly compare colors, but we can check that it's not nil
		XCTAssertNotNil(item.color)
	}
	
	func testConstantsConfiguration() async throws {
		// Test that configuration works correctly
		
		// Save original values
		let originalItemSize = try await HorizontalCollectionConstants.itemSize
		let originalItemSpacing = try await HorizontalCollectionConstants.itemSpacing
		let originalDebugMode = try await HorizontalCollectionConstants.debugMode
		let originalScrollBehaviorMode = try await HorizontalCollectionConstants.scrollBehaviorMode
		
		// Apply new configuration
		await HorizontalCollectionConstants.configure(
			itemSize: 100,
			itemSpacing: 25,
			debugMode: true,
			scrollBehaviorMode: .targetContentOffset
		)
		
		// Verify new values
		let newItemSize = try await HorizontalCollectionConstants.itemSize
		let newItemSpacing = try await HorizontalCollectionConstants.itemSpacing
		let newDebugMode = try await HorizontalCollectionConstants.debugMode
		let newScrollBehaviorMode = try await HorizontalCollectionConstants.scrollBehaviorMode
		
		XCTAssertEqual(newItemSize, 100)
		XCTAssertEqual(newItemSpacing, 25)
		XCTAssertTrue(newDebugMode)
		XCTAssertEqual(newScrollBehaviorMode, .targetContentOffset)
		
		// Restore original values for other tests
		await HorizontalCollectionConstants.configure(
			itemSize: originalItemSize,
			itemSpacing: originalItemSpacing,
			debugMode: originalDebugMode,
			scrollBehaviorMode: originalScrollBehaviorMode
		)
	}
	
	func testScreenWidthNonisolated() {
		// Test that screenWidth is accessible without async/await
		let width = HorizontalCollectionConstants.screenWidth
		XCTAssertGreaterThan(width, 0)
	}
	
	func testScrollBehaviorModes() {
		// Test that both scroll behavior modes are distinct
		let standardMode = ScrollBehaviorMode.standard
		let targetMode = ScrollBehaviorMode.targetContentOffset
		
		XCTAssertNotEqual(
			String(describing: standardMode),
			String(describing: targetMode)
		)
	}
}
import XCTest
import SwiftUI
@testable import CenteredHorizontalCollection

final class CenteredHorizontalCollectionTests: XCTestCase {
	func testItemInitialization() {
		// Test that Item initializes correctly
		let item = Item(id: 1, color: .red)
		XCTAssertEqual(item.id, 1)
		// We can't directly compare colors, but we can check that it's not nil
		XCTAssertNotNil(item.color)
	}
	
	func testConstantsConfiguration() {
		// Test that configuration works correctly
		
		// Save original values
		let originalItemSize = HorizontalCollectionConstants.itemSize
		let originalItemSpacing = HorizontalCollectionConstants.itemSpacing
		let originalDebugMode = HorizontalCollectionConstants.debugMode
		let originalScrollBehaviorMode = HorizontalCollectionConstants.scrollBehaviorMode
		
		// Apply new configuration
		HorizontalCollectionConstants.configure(
			itemSize: 100,
			itemSpacing: 25,
			debugMode: true,
			scrollBehaviorMode: .targetContentOffset
		)
		
		// Verify new values
		XCTAssertEqual(HorizontalCollectionConstants.itemSize, 100)
		XCTAssertEqual(HorizontalCollectionConstants.itemSpacing, 25)
		XCTAssertTrue(HorizontalCollectionConstants.debugMode)
		XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .targetContentOffset)
		
		// Restore original values for other tests
		HorizontalCollectionConstants.configure(
			itemSize: originalItemSize,
			itemSpacing: originalItemSpacing,
			debugMode: originalDebugMode,
			scrollBehaviorMode: originalScrollBehaviorMode
		)
	}
	
	func testScrollBehaviorModes() {
		// Test that both scroll behavior modes are distinct
		let standardMode = ScrollBehaviorMode.standard
		let targetMode = ScrollBehaviorMode.targetContentOffset
		
		XCTAssertNotEqual(
			String(describing: standardMode),
			String(describing: targetMode)
		)
	}
}
