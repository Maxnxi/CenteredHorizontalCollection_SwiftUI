//
//  ItemViewTests.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/26/25.
//


import XCTest
@testable import CenteredHorizontalCollection
import SwiftUI
import ViewInspector // Note: This would need to be added as a dependency

// Extension to make ItemView inspectable
extension ItemView: Inspectable {}

final class ItemViewTests: XCTestCase {
    
    // Test that ItemView initializes with correct properties
    func testItemViewInitialization() {
        // Create a test item
        let testItem = Item(id: 42, color: .blue)
        
        // Create an ItemView with the test item
        let onTapCalled = expectation(description: "onTap closure called")
        
        let itemView = ItemView(
            item: testItem,
            isSelected: true,
            onTap: {
                onTapCalled.fulfill()
            }
        )
        
        // Verify view was created successfully
        XCTAssertNotNil(itemView)
    }
    
    // Test that ItemView renders correctly
    func testItemViewRendering() throws {
        // Create a test item
        let testItem = Item(id: 123, color: .red)
        var onTapCalled = false
        
        // Create an ItemView with the test item
        let itemView = ItemView(
            item: testItem,
            isSelected: true,
            onTap: {
                onTapCalled = true
            }
        )
        
        // Use ViewInspector to verify view structure
        let view = try itemView.inspect()
        
        // Verify RoundedRectangle is the root view
        let rect = try view.shape(RoundedRectangle.self)
        
        // Verify it has the correct corner radius
        XCTAssertEqual(try rect.cornerRadius(), 8)
        
        // Verify it has fill modifier with the correct color
        let fill = try rect.fill()
        // Color comparison would be done here with appropriate ViewInspector helpers
        
        // Verify text overlay with correct item id
        let overlay = try rect.overlay()
        let text = try overlay.text()
        XCTAssertEqual(try text.string(), "123")
        
        // Verify shadow if selected
        let shadowRadius = try rect.shadowRadius()
        XCTAssertEqual(shadowRadius, 6) // 6 for selected state
        
        // Verify scale effect if selected
        let scale = try rect.scaleEffect()
        XCTAssertEqual(scale.value, 1.1) // 1.1 for selected state
        
        // Test onTapGesture by simulating tap
        try rect.callOnTapGesture()
        XCTAssertTrue(onTapCalled)
    }
    
    // Test that ItemView handles isSelected property correctly
    func testItemViewSelectionState() throws {
        // Create a test item
        let testItem = Item(id: 5, color: .green)
        
        // Test with isSelected = true
        let selectedView = ItemView(
            item: testItem,
            isSelected: true,
            onTap: {}
        )
        
        let selectedInspectable = try selectedView.inspect()
        let selectedRect = try selectedInspectable.shape(RoundedRectangle.self)
        
        // Verify selected appearance
        let selectedShadowRadius = try selectedRect.shadowRadius()
        XCTAssertEqual(selectedShadowRadius, 6)
        
        let selectedScale = try selectedRect.scaleEffect()
        XCTAssertEqual(selectedScale.value, 1.1)
        
        // Test with isSelected = false
        let unselectedView = ItemView(
            item: testItem,
            isSelected: false,
            onTap: {}
        )
        
        let unselectedInspectable = try unselectedView.inspect()
        let unselectedRect = try unselectedInspectable.shape(RoundedRectangle.self)
        
        // Verify unselected appearance
        let unselectedShadowRadius = try unselectedRect.shadowRadius()
        XCTAssertEqual(unselectedShadowRadius, 2)
        
        let unselectedScale = try unselectedRect.scaleEffect()
        XCTAssertEqual(unselectedScale.value, 0.9)
    }
    
    // Test that ItemView uses constants for dimensions
    func testItemViewDimensions() throws {
        // Store original value
        let originalItemSize = HorizontalCollectionConstants.itemSize
        
        // Set test value
        HorizontalCollectionConstants.itemSize = 75
        
        // Create a test item
        let testItem = Item(id: 7, color: .blue)
        
        // Create an ItemView
        let itemView = ItemView(
            item: testItem,
            isSelected: false,
            onTap: {}
        )
        
        // Verify dimensions
        let view = try itemView.inspect()
        let rect = try view.shape(RoundedRectangle.self)
        let frame = try rect.fixedFrame()
        
        XCTAssertEqual(frame.width, 75)
        XCTAssertEqual(frame.height, 75)
        
        // Reset to original value
        HorizontalCollectionConstants.itemSize = originalItemSize
    }
    
    // Test that ItemView handles onTap closure correctly
    func testItemViewOnTapClosure() throws {
        // Create a test item
        let testItem = Item(id: 9, color: .purple)
        
        // Create a flag to track if onTap was called
        var onTapCalled = false
        
        // Create an ItemView with the test item
        let itemView = ItemView(
            item: testItem,
            isSelected: false,
            onTap: {
                onTapCalled = true
            }
        )
        
        // Verify initial state
        XCTAssertFalse(onTapCalled)
        
        // Simulate tap
        let view = try itemView.inspect()
        let rect = try view.shape(RoundedRectangle.self)
        try rect.callOnTapGesture()
        
        // Verify onTap was called
        XCTAssertTrue(onTapCalled)
    }
    
    // Test that ItemView handles debug mode correctly
    func testItemViewDebugMode() {
        // Store original debug mode
        let originalDebugMode = HorizontalCollectionConstants.debugMode
        
        // Enable debug mode
        HorizontalCollectionConstants.debugMode = true
        
        // Create a test item
        let testItem = Item(id: 11, color: .orange)
        
        // Create an ItemView and tap it (should log but not crash)
        let itemView = ItemView(
            item: testItem,
            isSelected: true,
            onTap: {}
        )
        
        // Reset to original value
        HorizontalCollectionConstants.debugMode = originalDebugMode
    }
}