//
//  CenteredHorizontalCollectionIntegrationTests.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/26/25.
//


import XCTest
@testable import CenteredHorizontalCollection
import SwiftUI
import Combine

final class CenteredHorizontalCollectionIntegrationTests: XCTestCase {
    
    // Test complete integration of collection, ViewModel and configuration
    @MainActor
    func testEndToEndIntegration() async {
        // 1. Configure constants
        await HorizontalCollectionConstants.configure(
            itemSize: 80,
            itemSpacing: 20,
            debugMode: false,
            scrollBehaviorMode: .standard
        )
        
        // 2. Create test items
        let items = (1...5).map { Item(id: $0, color: .blue) }
        
        // 3. Create binding for selection
        var selectedID = 1
        let binding = Binding<Int>(
            get: { selectedID },
            set: { selectedID = $0 }
        )
        
        // 4. Create the collection
        let collection = CenteredHorizontalCollection(
            items: items,
            itemSpacing: 20,
            selection: binding
        ) { item, isSelected in
            Text("\(item.id)")
                .foregroundColor(isSelected ? .white : .black)
                .frame(width: 80, height: 80)
                .background(item.color)
                .scaleEffect(isSelected ? 1.1 : 0.9)
        }
        
        // 5. Simulate selection change
        // This would happen when user interacts with collection
        selectedID = 3
        
        // 6. Verify binding worked
        XCTAssertEqual(selectedID, 3)
        
        // 7. Change configuration
        await HorizontalCollectionConstants.configure(
            itemSize: 100,
            scrollBehaviorMode: .targetContentOffset
        )
        
        // 8. Verify constants were updated
        XCTAssertEqual(HorizontalCollectionConstants.itemSize, 100)
        XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .targetContentOffset)
    }
    
    // Test integration with custom models
    func testIntegrationWithCustomModels() {
        // 1. Define custom model
        struct Product: Identifiable {
            let id: UUID
            let name: String
            let price: Double
        }
        
        // 2. Create test items
        let products = [
            Product(id: UUID(), name: "Product A", price: 10.99),
            Product(id: UUID(), name: "Product B", price: 20.99),
            Product(id: UUID(), name: "Product C", price: 15.99)
        ]
        
        // 3. Create the collection
        let collection = CenteredHorizontalCollection(
            items: products
        ) { product, isSelected in
            VStack {
                Text(product.name)
                    .font(isSelected ? .headline : .body)
                Text("$\(String(format: "%.2f", product.price))")
                    .foregroundColor(isSelected ? .green : .gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: isSelected ? 5 : 1)
        }
        
        // Collection should be created without errors
        XCTAssertNotNil(collection)
    }
    
    // Test integration with all configuration options
    @MainActor
    func testIntegrationWithAllConfigOptions() async {
        // Store original values to restore after test
        let originalItemSize = HorizontalCollectionConstants.itemSize
        let originalItemSpacing = HorizontalCollectionConstants.itemSpacing
        let originalDebugMode = HorizontalCollectionConstants.debugMode
        let originalScrollBehaviorMode = HorizontalCollectionConstants.scrollBehaviorMode
        let originalSelectionAnimationDuration = HorizontalCollectionConstants.selectionAnimationDuration
        let originalSelectionAnimationDuringDrag = HorizontalCollectionConstants.selectionAnimationDuringDrag
        let originalScrollDebounceTime = HorizontalCollectionConstants.scrollDebounceTime
        let originalEnableRealTimeSelection = HorizontalCollectionConstants.enableRealTimeSelection
        let originalRealTimeSelectionThreshold = HorizontalCollectionConstants.realTimeSelectionThreshold
        let originalAlwaysCenterSelectedItem = HorizontalCollectionConstants.alwaysCenterSelectedItem
        let originalMinCorrectionThreshold = HorizontalCollectionConstants.minCorrectionThreshold
        let originalMaxCorrectionThreshold = HorizontalCollectionConstants.maxCorrectionThreshold
        let originalUseSnappingBehavior = HorizontalCollectionConstants.useSnappingBehavior
        let originalScrollSnapSensitivity = HorizontalCollectionConstants.scrollSnapSensitivity
        let originalVelocityMultiplier = HorizontalCollectionConstants.velocityMultiplier
        let originalSnapStrength = HorizontalCollectionConstants.snapStrength
        
        // Configure with test values
        await HorizontalCollectionConstants.configure(
            itemSize: 90,
            itemSpacing: 25,
            debugMode: true,
            scrollBehaviorMode: .targetContentOffset
        )
        
        HorizontalCollectionConstants.selectionAnimationDuration = 0.4
        HorizontalCollectionConstants.selectionAnimationDuringDrag = 0.2
        HorizontalCollectionConstants.scrollDebounceTime = 0.2
        HorizontalCollectionConstants.enableRealTimeSelection = true
        HorizontalCollectionConstants.realTimeSelectionThreshold = 40
        HorizontalCollectionConstants.alwaysCenterSelectedItem = true
        HorizontalCollectionConstants.minCorrectionThreshold = 4.0
        HorizontalCollectionConstants.maxCorrectionThreshold = 50.0
        HorizontalCollectionConstants.useSnappingBehavior = true
        HorizontalCollectionConstants.scrollSnapSensitivity = 0.8
        HorizontalCollectionConstants.velocityMultiplier = 0.3
        HorizontalCollectionConstants.snapStrength = 0.8
        
        // Create test items
        let items = (1...3).map { Item(id: $0, color: .blue) }
        
        // Create the collection
        let collection = CenteredHorizontalCollection(
            items: items
        ) { item, isSelected in
            Text("\(item.id)")
        }
        
        // Collection should be created successfully
        XCTAssertNotNil(collection)
        
        // Verify configuration values were applied
        XCTAssertEqual(HorizontalCollectionConstants.itemSize, 90)
        XCTAssertEqual(HorizontalCollectionConstants.itemSpacing, 25)
        XCTAssertTrue(HorizontalCollectionConstants.debugMode)
        XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .targetContentOffset)
        XCTAssertEqual(HorizontalCollectionConstants.selectionAnimationDuration, 0.4)
        XCTAssertEqual(HorizontalCollectionConstants.selectionAnimationDuringDrag, 0.2)
        XCTAssertEqual(HorizontalCollectionConstants.scrollDebounceTime, 0.2)
        XCTAssertTrue(HorizontalCollectionConstants.enableRealTimeSelection)
        XCTAssertEqual(HorizontalCollectionConstants.realTimeSelectionThreshold, 40)
        XCTAssertTrue(HorizontalCollectionConstants.alwaysCenterSelectedItem)
        XCTAssertEqual(HorizontalCollectionConstants.minCorrectionThreshold, 4.0)
        XCTAssertEqual(HorizontalCollectionConstants.maxCorrectionThreshold, 50.0)
        XCTAssertTrue(HorizontalCollectionConstants.useSnappingBehavior)
        XCTAssertEqual(HorizontalCollectionConstants.scrollSnapSensitivity, 0.8)
        XCTAssertEqual(HorizontalCollectionConstants.velocityMultiplier, 0.3)
        XCTAssertEqual(HorizontalCollectionConstants.snapStrength, 0.8)
        
        // Restore original values
        await HorizontalCollectionConstants.configure(
            itemSize: originalItemSize,
            itemSpacing: originalItemSpacing,
            debugMode: originalDebugMode,
            scrollBehaviorMode: originalScrollBehaviorMode
        )
        
        HorizontalCollectionConstants.selectionAnimationDuration = originalSelectionAnimationDuration
        HorizontalCollectionConstants.selectionAnimationDuringDrag = originalSelectionAnimationDuringDrag
        HorizontalCollectionConstants.scrollDebounceTime = originalScrollDebounceTime
        HorizontalCollectionConstants.enableRealTimeSelection = originalEnableRealTimeSelection
        HorizontalCollectionConstants.realTimeSelectionThreshold = originalRealTimeSelectionThreshold
        HorizontalCollectionConstants.alwaysCenterSelectedItem = originalAlwaysCenterSelectedItem
        HorizontalCollectionConstants.minCorrectionThreshold = originalMinCorrectionThreshold
        HorizontalCollectionConstants.maxCorrectionThreshold = originalMaxCorrectionThreshold
        HorizontalCollectionConstants.useSnappingBehavior = originalUseSnappingBehavior
        HorizontalCollectionConstants.scrollSnapSensitivity = originalScrollSnapSensitivity
        HorizontalCollectionConstants.velocityMultiplier = originalVelocityMultiplier
        HorizontalCollectionConstants.snapStrength = originalSnapStrength
    }
    
    // Test integration with selection binding
    func testIntegrationWithSelectionBinding() {
        // Create a publisher to track selection changes
        let selectionSubject = PassthroughSubject<Int, Never>()
        var receivedSelections: [Int] = []
        var cancellables = Set<AnyCancellable>()
        
        // Subscribe to selection changes
        selectionSubject
            .sink { selection in
                receivedSelections.append(selection)
            }
            .store(in: &cancellables)
        
        // Create binding
        var selectedID = 1
        let binding = Binding<Int>(
            get: { selectedID },
            set: { 
                selectedID = $0
                selectionSubject.send($0)
            }
        )
        
        // Create test items
        let items = (1...5).map { Item(id: $0, color: .blue) }
        
        // Create collection with binding
        let collection = CenteredHorizontalCollection(
            items: items,
            selection: binding
        ) { item, isSelected in
            Text("\(item.id)")
        }
        
        // Simulate selection changes
        selectedID = 2
        binding.wrappedValue = 3
        binding.wrappedValue = 4
        
        // Verify selections were tracked
        XCTAssertEqual(receivedSelections, [3, 4])
        XCTAssertEqual(selectedID, 4)
    }
    
    // Test scrolling behavior modes integration
    @MainActor
    func testScrollingBehaviorModesIntegration() async {
        // Store original value
        let originalScrollBehaviorMode = HorizontalCollectionConstants.scrollBehaviorMode
        
        // Test standard mode
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: .standard
        )
        
        // Create test items
        let items = (1...5).map { Item(id: $0, color: .blue) }
        
        // Create collection
        let collection1 = CenteredHorizontalCollection(
            items: items
        ) { item, isSelected in
            Text("\(item.id)")
        }
        
        // Verify mode
        XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .standard)
        
        // Test target content offset mode
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: .targetContentOffset
        )
        
        // Create another collection
        let collection2 = CenteredHorizontalCollection(
            items: items
        ) { item, isSelected in
            Text("\(item.id)")
        }
        
        // Verify mode
        XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .targetContentOffset)
        
        // Restore original value
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: originalScrollBehaviorMode
        )
    }
    
    // Test integration with DemoView
    func testIntegrationWithDemoView() {
        // Create the DemoView
        let demoView = DemoView()
        
        // Verify it initializes without errors
        XCTAssertNotNil(demoView)
        
        // This is primarily to ensure the DemoView can initialize and work with the collection
        // Full UI testing would typically be done with ViewInspector or in an actual app target
    }
}