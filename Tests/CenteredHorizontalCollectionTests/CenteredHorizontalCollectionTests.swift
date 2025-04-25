//
//  File.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/25/25.
//

//import Testing
//@testable import CenteredHorizontalCollection
//
//@Test func example() async throws {
//	// Write your test here and use APIs like `#expect(...)` to check expected conditions.
//}

import XCTest
@testable import CenteredHorizontalCollection
import SwiftUI

final class CenteredHorizontalCollectionTests: XCTestCase {
	
	// Test the creation of collection with default parameters
	func testCollectionInitialization() {
		// Create sample items
		let items = (1...5).map { Item(id: $0, color: .blue) }
		
		// Initialize collection with default parameters
		let collection = CenteredHorizontalCollection(items: items) { item, isSelected in
			Text("\(item.id)")
		}
		
		// Assert collection was created (no initialization error)
		XCTAssertNotNil(collection)
	}
	
	// Test collection with selection binding
	func testCollectionWithSelectionBinding() {
		// Create sample items
		let items = (1...5).map { Item(id: $0, color: .blue) }
		
		// Create binding
		let selectedID = Binding.constant(2)
		
		// Initialize collection with selection binding
		let collection = CenteredHorizontalCollection(items: items, selection: selectedID) { item, isSelected in
			Text("\(item.id)")
		}
		
		// Assert collection was created with binding
		XCTAssertNotNil(collection)
	}
	
	// Test the conversion of non-integer IDs
	func testNonIntegerIDHandling() {
		// Define a test struct with UUID as identifier
		struct TestItem: Identifiable {
			let id: UUID
			let value: String
		}
		
		// Create sample items with UUID identifiers
		let items = [
			TestItem(id: UUID(), value: "Item 1"),
			TestItem(id: UUID(), value: "Item 2")
		]
		
		// Initialize collection with non-integer IDs
		let collection = CenteredHorizontalCollection(items: items) { item, isSelected in
			Text(item.value)
		}
		
		// Assert collection was created (no initialization error)
		XCTAssertNotNil(collection)
	}
	
	// Test constants configuration
	func testConstantsConfiguration() async {
		// Store original values to restore after test
		let originalItemSize = HorizontalCollectionConstants.itemSize
		let originalItemSpacing = HorizontalCollectionConstants.itemSpacing
		let originalDebugMode = HorizontalCollectionConstants.debugMode
		let originalScrollBehaviorMode = HorizontalCollectionConstants.scrollBehaviorMode
		
		// Configure with new test values
		await HorizontalCollectionConstants.configure(
			itemSize: 100,
			itemSpacing: 25,
			debugMode: true,
			scrollBehaviorMode: .targetContentOffset
		)
		
		// Assert values were updated
		XCTAssertEqual(HorizontalCollectionConstants.itemSize, 100)
		XCTAssertEqual(HorizontalCollectionConstants.itemSpacing, 25)
		XCTAssertTrue(HorizontalCollectionConstants.debugMode)
		XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .targetContentOffset)
		
		// Reset to original values
		await HorizontalCollectionConstants.configure(
			itemSize: originalItemSize,
			itemSpacing: originalItemSpacing,
			debugMode: originalDebugMode,
			scrollBehaviorMode: originalScrollBehaviorMode
		)
	}
	
	// Test individual configuration properties
	func testIndividualConfigurationProperties() async {
		// Store original values
		let originalAnimationDuration = HorizontalCollectionConstants.selectionAnimationDuration
		let originalAnimationDuringDrag = HorizontalCollectionConstants.selectionAnimationDuringDrag
		
		// Update individual properties
		HorizontalCollectionConstants.selectionAnimationDuration = 0.5
		HorizontalCollectionConstants.selectionAnimationDuringDrag = 0.2
		
		// Assert values were updated
		XCTAssertEqual(HorizontalCollectionConstants.selectionAnimationDuration, 0.5)
		XCTAssertEqual(HorizontalCollectionConstants.selectionAnimationDuringDrag, 0.2)
		
		// Reset to original values
		HorizontalCollectionConstants.selectionAnimationDuration = originalAnimationDuration
		HorizontalCollectionConstants.selectionAnimationDuringDrag = originalAnimationDuringDrag
	}
	
	// Test debug utility
	func testDebugUtility() {
		// Store original debug mode
		let originalDebugMode = HorizontalCollectionConstants.debugMode
		
		// Enable debug mode
		HorizontalCollectionConstants.debugMode = true
		
		// Test debug print (should not crash)
		DebugUtility.debugPrint(.general, "Test message")
		DebugUtility.logOffset(id: 1, offset: 10.5)
		DebugUtility.logSelectionChange(from: 1, to: 2)
		DebugUtility.logCorrectionDecision(id: 1, offset: 5.0, needsCorrection: true)
		DebugUtility.logDragEvent(isDragging: true)
		DebugUtility.logTimerEvent(action: "Test timer event")
		
		// Test with debug mode disabled
		HorizontalCollectionConstants.debugMode = false
		
		// These should do nothing but not crash
		DebugUtility.debugPrint(.general, "Test message")
		DebugUtility.logOffset(id: 1, offset: 10.5)
		
		// Reset to original value
		HorizontalCollectionConstants.debugMode = originalDebugMode
	}
	
	// Test OffsetPreferenceKey
	func testOffsetPreferenceKey() {
		// Create test offsets
		let offsets1: [Int: CGFloat] = [1: 10.0, 2: 20.0]
		let offsets2: [Int: CGFloat] = [2: 25.0, 3: 30.0]
		
		// Initialize with default value
		var result = OffsetPreferenceKey.defaultValue
		
		// Verify default is empty dictionary
		XCTAssertTrue(result.isEmpty)
		
		// Reduce with first value
		OffsetPreferenceKey.reduce(value: &result, nextValue: { offsets1 })
		
		// Verify first reduction
		XCTAssertEqual(result[1], 10.0)
		XCTAssertEqual(result[2], 20.0)
		
		// Reduce with second value (should override first for key 2)
		OffsetPreferenceKey.reduce(value: &result, nextValue: { offsets2 })
		
		// Verify second reduction merged correctly
		XCTAssertEqual(result[1], 10.0)
		XCTAssertEqual(result[2], 25.0) // Updated from offsets2
		XCTAssertEqual(result[3], 30.0) // Added from offsets2
	}
	
	// Test Item model
	func testItemModel() {
		// Create a test item
		let item = Item(id: 42, color: .red)
		
		// Verify properties
		XCTAssertEqual(item.id, 42)
		XCTAssertEqual(item.color, .red)
	}
	
	// Test view model initialization
	func testViewModelInitialization() {
		let viewModel = CenteredScrollViewModel()
		
		// Verify default values
		XCTAssertEqual(viewModel.selectedID, 1)
		XCTAssertFalse(viewModel.isDragging)
		XCTAssertFalse(viewModel.isManuallySelected)
	}
	
	// Test manual item selection
	func testManualItemSelection() {
		let viewModel = CenteredScrollViewModel()
		
		// Initial state
		XCTAssertEqual(viewModel.selectedID, 1)
		XCTAssertFalse(viewModel.isManuallySelected)
		
		// Select item
		viewModel.selectItem(3)
		
		// Verify selection changed
		XCTAssertEqual(viewModel.selectedID, 3)
		XCTAssertTrue(viewModel.isManuallySelected)
	}
	
	// Test binding to external selection
	func testExternalSelectionBinding() {
		let viewModel = CenteredScrollViewModel()
		
		// Create a binding
		var selectionValue = 2
		let binding = Binding(
			get: { selectionValue },
			set: { selectionValue = $0 }
		)
		
		// Bind to external selection
		viewModel.bindToExternalSelection(binding)
		
		// Verify view model's selection was updated
		XCTAssertEqual(viewModel.selectedID, 2)
		
		// Change view model selection
		viewModel.selectItem(4)
		
		// Verify binding was updated
		XCTAssertEqual(selectionValue, 4)
	}
	
	// Test next/previous item selection
	func testNextPreviousSelection() {
		let viewModel = CenteredScrollViewModel()
		
		// Initial state
		XCTAssertEqual(viewModel.selectedID, 1)
		
		// Mock current offsets (this is normally populated by scroll view)
		viewModel.updateOffsets([1: 0.0, 2: 100.0, 3: 200.0])
		
		// Select next
		viewModel.selectNextItem()
		XCTAssertEqual(viewModel.selectedID, 2)
		
		// Select next again
		viewModel.selectNextItem()
		XCTAssertEqual(viewModel.selectedID, 3)
		
		// Select next at max (should stay at 3)
		viewModel.selectNextItem()
		XCTAssertEqual(viewModel.selectedID, 3)
		
		// Select previous
		viewModel.selectPreviousItem()
		XCTAssertEqual(viewModel.selectedID, 2)
		
		// Select previous again
		viewModel.selectPreviousItem()
		XCTAssertEqual(viewModel.selectedID, 1)
		
		// Select previous at min (should stay at 1)
		viewModel.selectPreviousItem()
		XCTAssertEqual(viewModel.selectedID, 1)
	}
	
	// Test drag state
	func testDragState() {
		let viewModel = CenteredScrollViewModel()
		
		// Initial state
		XCTAssertFalse(viewModel.isDragging)
		
		// Start dragging
		viewModel.startDragging()
		XCTAssertTrue(viewModel.isDragging)
		
		// End dragging
		viewModel.endDragging()
		XCTAssertFalse(viewModel.isDragging)
	}
}
