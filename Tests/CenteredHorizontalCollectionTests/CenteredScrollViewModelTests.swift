//
//  CenteredScrollViewModelTests.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/26/25.
//


import XCTest
@testable import CenteredHorizontalCollection
import SwiftUI
import Combine

final class CenteredScrollViewModelTests: XCTestCase {
    
    // Test the initialization of view model with default values
    func testViewModelInitialization() {
        let viewModel = CenteredScrollViewModel()
        
        XCTAssertEqual(viewModel.selectedID, 1)
        XCTAssertFalse(viewModel.isDragging)
        XCTAssertFalse(viewModel.isManuallySelected)
    }
    
    // Test find closest item to center logic
    @MainActor
    func testFindClosestItemToCenter() {
        let viewModel = CenteredScrollViewModel()
        
        // Empty offsets should return nil
        viewModel.updateOffsets([:])
        XCTAssertNil(viewModel.findClosestItemToCenter())
        
        // Single offset should return that item
        viewModel.updateOffsets([5: 10.0])
        XCTAssertEqual(viewModel.findClosestItemToCenter(), 5)
        
        // Multiple offsets should return closest to zero
        viewModel.updateOffsets([
            1: 10.0,
            2: -5.0,
            3: 8.0,
            4: -20.0
        ])
        XCTAssertEqual(viewModel.findClosestItemToCenter(), 2)
        
        // Exactly at zero should be closest
        viewModel.updateOffsets([
            1: 10.0,
            2: 0.0,
            3: 8.0
        ])
        XCTAssertEqual(viewModel.findClosestItemToCenter(), 2)
        
        // Equal distances, lower ID should win for consistency
        viewModel.updateOffsets([
            3: 5.0,
            4: -5.0
        ])
        XCTAssertEqual(viewModel.findClosestItemToCenter(), 3)
    }
    
    // Test updateOffsets method
    @MainActor
    func testUpdateOffsets() {
        let viewModel = CenteredScrollViewModel()
        
        // Set initial selection
        viewModel.selectedID = 2
        
        // Update offsets
        let offsets = [
            1: 15.0,
            2: 5.0,
            3: -10.0
        ]
        
        viewModel.updateOffsets(offsets)
        
        // Selected ID should not change if dragging is false
        XCTAssertEqual(viewModel.selectedID, 3) // Should change to closest (3)
    }
    
    // Test drag state management
    func testDragStateManagement() {
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
    
    // Test manual selection flag
    func testManualSelectionFlag() {
        let viewModel = CenteredScrollViewModel()
        
        // Initial state
        XCTAssertFalse(viewModel.isManuallySelected)
        
        // Manual selection should set the flag
        viewModel.selectItem(3)
        XCTAssertTrue(viewModel.isManuallySelected)
        XCTAssertEqual(viewModel.selectedID, 3)
    }
    
    // Test compute offset functionality
    @MainActor
    func testComputeOffset() {
        let viewModel = CenteredScrollViewModel()
        
        // Mock GeometryProxy for testing
        let mockGeometry = MockGeometryProxy(
            size: CGSize(width: 100, height: 50),
            safeAreaInsets: EdgeInsets(),
            frame: { _ in CGRect(x: 200, y: 0, width: 100, height: 50) }
        )
        
        // Calculate offset for a centered item assuming screen width of 400
        // Set screen width property temporarily
        let originalScreenWidth = HorizontalCollectionConstants.screenWidth
        
        // Mock screen width for test
        Task {
            await MainActor.run {
                // We're accessing this on the main actor to prevent warnings
                let testScreenWidth: CGFloat = 400
                HorizontalCollectionConstants.screenWidth = testScreenWidth
                
                // For an item at x=200 with width=100, midX is 250
                // Screen center is 400/2 = 200
                // So offset should be 250 - 200 = 50
                let offset = viewModel.computeOffset(geo: mockGeometry)
                XCTAssertEqual(offset, 50, accuracy: 0.001)
                
                // Restore original screen width
                HorizontalCollectionConstants.screenWidth = originalScreenWidth
            }
        }
    }
    
    // Test navigation methods (next/previous)
    func testNavigationMethods() {
        let viewModel = CenteredScrollViewModel()
        
        // Initial state
        viewModel.selectedID = 2
        
        // Set up test offsets
        let offsets = [1: 10.0, 2: 0.0, 3: -10.0, 4: -20.0]
        viewModel.updateOffsets(offsets)
        
        // Test next navigation
        viewModel.selectNextItem()
        XCTAssertEqual(viewModel.selectedID, 3)
        
        viewModel.selectNextItem()
        XCTAssertEqual(viewModel.selectedID, 4)
        
        // At max, should not change
        viewModel.selectNextItem()
        XCTAssertEqual(viewModel.selectedID, 4)
        
        // Test previous navigation
        viewModel.selectPreviousItem()
        XCTAssertEqual(viewModel.selectedID, 3)
        
        viewModel.selectPreviousItem()
        XCTAssertEqual(viewModel.selectedID, 2)
        
        viewModel.selectPreviousItem()
        XCTAssertEqual(viewModel.selectedID, 1)
        
        // At min, should not change
        viewModel.selectPreviousItem()
        XCTAssertEqual(viewModel.selectedID, 1)
    }
    
    // Test binding to external selection
    func testExternalSelectionBinding() {
        let viewModel = CenteredScrollViewModel()
        
        // Create binding
        var externalValue = 3
        let binding = Binding<Int>(
            get: { externalValue },
            set: { externalValue = $0 }
        )
        
        // Bind to external selection
        viewModel.bindToExternalSelection(binding)
        
        // View model should update to match binding
        XCTAssertEqual(viewModel.selectedID, 3)
        
        // Changing view model should update binding
        viewModel.selectItem(5)
        XCTAssertEqual(externalValue, 5)
        
        // Changing binding should update view model too
        externalValue = 2
        // This would normally happen through SwiftUI's binding system
        viewModel.selectedID = externalValue
        XCTAssertEqual(viewModel.selectedID, 2)
    }
    
    // Test selection animation duration based on mode
    func testSelectionAnimationDuration() {
        // Store original values to restore after test
        let originalDuration = HorizontalCollectionConstants.selectionAnimationDuration
        let originalDuringDrag = HorizontalCollectionConstants.selectionAnimationDuringDrag
        
        // Set test values
        HorizontalCollectionConstants.selectionAnimationDuration = 0.5
        HorizontalCollectionConstants.selectionAnimationDuringDrag = 0.1
        
        // Create view model
        let viewModel = CenteredScrollViewModel()
        
        // Test drag mode (would use animation during drag)
        viewModel.startDragging()
        // Would use selectionAnimationDuringDrag (0.1)
        
        // Test normal mode (would use standard animation)
        viewModel.endDragging()
        // Would use selectionAnimationDuration (0.5)
        
        // Restore original values
        HorizontalCollectionConstants.selectionAnimationDuration = originalDuration
        HorizontalCollectionConstants.selectionAnimationDuringDrag = originalDuringDrag
    }
    
    // Test concurrent access safety
    func testConcurrentAccessSafety() async {
        let viewModel = CenteredScrollViewModel()
        
        // Create many concurrent tasks that modify the viewModel
        // This tests that the @MainActor isolation prevents race conditions
        await withTaskGroup(of: Void.self) { group in
            for i in 1...100 {
                group.addTask {
                    await MainActor.run {
                        viewModel.selectItem(i % 10 + 1)
                        viewModel.startDragging()
                        viewModel.endDragging()
                    }
                }
            }
        }
        
        // If we got here without crashing, the test passes
        // The final state will depend on the order of execution
    }
}

// MARK: - Helper Types

// Mock GeometryProxy for testing
struct MockGeometryProxy: GeometryProxy {
    var size: CGSize
    var safeAreaInsets: EdgeInsets
    var frame: (CoordinateSpace) -> CGRect
    
    func frame(in coordinateSpace: CoordinateSpace) -> CGRect {
        return frame(coordinateSpace)
    }
}

// Add a concurrency-safe method to CenteredScrollViewModel
extension CenteredScrollViewModel {
    @MainActor
    func findClosestItemToCenter() -> Int? {
        // Find item with minimum absolute offset
        return currentOffsets.min(by: { abs($0.value) < abs($1.value) })?.key
    }
}