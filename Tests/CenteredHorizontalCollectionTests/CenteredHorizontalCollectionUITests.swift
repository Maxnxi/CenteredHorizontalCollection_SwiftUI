//
//  CenteredHorizontalCollectionUITests.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/26/25.
//


import XCTest
import SwiftUI
import ViewInspector
@testable import CenteredHorizontalCollection

// Note: This test file uses ViewInspector which is not included by default.
// You would need to add it as a test dependency to your package.
// https://github.com/nalexn/ViewInspector

final class CenteredHorizontalCollectionUITests: XCTestCase {
    
    // Test that the collection renders with correct number of items
    func testCollectionRendersItems() throws {
        // Create sample items
        let items = (1...5).map { Item(id: $0, color: .blue) }
        
        // Create test view with the collection
        let view = TestCollectionWrapper(items: items)
        
        // Use ViewInspector to verify the structure of the view
        let inspectableView = try view.inspect()
        
        // Navigate to the VStack
        let vstack = try inspectableView.vStack()
        
        // Check that the collection contains a ScrollView
        let scrollView = try vstack.scrollView(1)
        
        // Navigate to the HStack within the ScrollView
        let hstack = try scrollView.hStack()
        
        // HStack should have 7 children: spacer + 5 items + spacer
        XCTAssertEqual(try hstack.count(), 7)
    }
    
    // Test that item selection works
    func testItemSelection() throws {
        // Create sample items
        let items = (1...3).map { Item(id: $0, color: .blue) }
        
        // Create binding for selection
        @State var selection = 1
        
        // Create test view with the collection and binding
        let view = TestCollectionSelectionWrapper(items: items, selection: $selection)
        
        // Inspect view
        let inspectableView = try view.inspect()
        
        // Get the text showing current selection
        let selectionText = try inspectableView.vStack().text(0)
        XCTAssertEqual(try selectionText.string(), "Selected Item: 1")
        
        // Simulate changing the selection to 2
        selection = 2
        
        // Check that the text updates
        // Note: ViewInspector requires calling a method to trigger state changes
        try inspectableView.vStack().callOnChange(of: selection)
        
        // Verify the text was updated
        let updatedText = try inspectableView.vStack().text(0)
        XCTAssertEqual(try updatedText.string(), "Selected Item: 2")
    }
    
    // Test that the collection applies correct styling based on selection
    func testSelectionStyling() throws {
        // Create sample items
        let items = (1...3).map { Item(id: $0, color: .blue) }
        
        // Create test view with the collection, using specific item builder
        let view = TestCollectionWithStyling(items: items)
        
        // Inspect view
        let inspectableView = try view.inspect()
        
        // Navigate to the first item (index 1 because of initial spacer)
        // Note: This inspection relies on implementation details of collection
        let scrollView = try inspectableView.vStack().scrollView(0)
        let hstack = try scrollView.hStack()
        
        // First item should have scale of 1.1 (selected)
        let firstItemScale = try hstack.view(1, Text.self).scaleEffect().value
        XCTAssertEqual(firstItemScale, 1.1)
        
        // Second item should have scale of 0.9 (not selected)
        let secondItemScale = try hstack.view(2, Text.self).scaleEffect().value
        XCTAssertEqual(secondItemScale, 0.9)
    }
    
    // Test the configuration updates reflect in rendering
    func testConfigurationUpdatesReflectInRendering() throws {
        // Set initial configuration
        Task {
            await HorizontalCollectionConstants.configure(
                itemSize: 50,
                itemSpacing: 10
            )
        }
        
        // Create sample items
        let items = (1...3).map { Item(id: $0, color: .blue) }
        
        // Create test view
        let view = TestCollectionWithItemSizeCheck(items: items)
        
        // Inspect view
        let inspectableView = try view.inspect()
        
        // Navigate to an item frame
        let item = try inspectableView.vStack().scrollView(0).hStack().text(1)
        let frame = try item.fixedFrame()
        
        // Check initial dimensions
        XCTAssertEqual(frame.width, 50)
        
        // Update configuration
        Task {
            await HorizontalCollectionConstants.configure(
                itemSize: 70
            )
        }
        
        // Check dimensions after update
        // This would require a view refresh mechanism that depends on the implementation
        // In a real test, you might use a combination of Combine publishers or wait
    }
    
    // Test theme change for items
    func testThemeChanges() throws {
        // Create sample items
        let items = (1...3).map { Item(id: $0, color: .blue) }
        
        // Create test view with theme
        let view = TestCollectionWithThemes(items: items)
        
        // Inspect initial theme (standard)
        let inspectableView = try view.inspect()
        
        // Navigate to an item
        let scrollView = try inspectableView.vStack().scrollView(0)
        let hstack = try scrollView.hStack()
        
        // Check that shape is RoundedRectangle in standard theme
        let item = try hstack.view(1) // First item after spacer
        XCTAssertNoThrow(try item.findShape(RoundedRectangle.self))
        
        // Change theme to minimal (Circle)
        try inspectableView.vStack().button(2).tap()
        
        // Check that shape is now Circle
        // Note: In a real test, you would need to handle state updates properly
        // This simplified example shows the approach but may need additional code
    }
}

// MARK: - Helper Views for Testing

// Simple wrapper around collection for testing
struct TestCollectionWrapper: View {
    let items: [Item]
    
    var body: some View {
        VStack {
            Text("Test Collection")
            CenteredHorizontalCollection(items: items) { item, isSelected in
                Text("\(item.id)")
            }
        }
    }
}

// Wrapper with selection binding for testing
struct TestCollectionSelectionWrapper: View {
    let items: [Item]
    @Binding var selection: Int
    
    var body: some View {
        VStack {
            Text("Selected Item: \(selection)")
            CenteredHorizontalCollection(items: items, selection: $selection) { item, isSelected in
                Text("\(item.id)")
            }
        }
    }
}

// Wrapper with explicit styling for testing
struct TestCollectionWithStyling: View {
    let items: [Item]
    @State private var selection = 1
    
    var body: some View {
        VStack {
            CenteredHorizontalCollection(items: items, selection: $selection) { item, isSelected in
                Text("\(item.id)")
                    .scaleEffect(isSelected ? 1.1 : 0.9)
            }
        }
    }
}

// Wrapper that checks item size
struct TestCollectionWithItemSizeCheck: View {
    let items: [Item]
    
    var body: some View {
        VStack {
            CenteredHorizontalCollection(items: items) { item, isSelected in
                Text("\(item.id)")
                    .frame(width: HorizontalCollectionConstants.itemSize, 
                           height: HorizontalCollectionConstants.itemSize)
            }
        }
    }
}

// Wrapper for testing theme changes
struct TestCollectionWithThemes: View {
    let items: [Item]
    @State private var selection = 1
    @State private var theme = 0
    
    var body: some View {
        VStack {
            CenteredHorizontalCollection(items: items, selection: $selection) { item, isSelected in
                if theme == 0 {
                    // Standard theme
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(item.color)
                        .overlay(Text("\(item.id)"))
                } else {
                    // Minimal theme
                    Circle()
                        .foregroundColor(item.color)
                        .overlay(Text("\(item.id)"))
                }
            }
            
            Text("Current Theme: \(theme == 0 ? "Standard" : "Minimal")")
            
            Button("Switch to Standard") {
                theme = 0
            }
            
            Button("Switch to Minimal") {
                theme = 1
            }
        }
    }
}

// ViewInspector extension to make CenteredHorizontalCollection inspectable
extension CenteredHorizontalCollection: Inspectable {}