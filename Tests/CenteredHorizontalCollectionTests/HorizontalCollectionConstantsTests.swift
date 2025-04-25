//
//  HorizontalCollectionConstantsTests.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/26/25.
//


import XCTest
@testable import CenteredHorizontalCollection
import SwiftUI

final class HorizontalCollectionConstantsTests: XCTestCase {
    
    // Test default values
    func testDefaultValues() {
        XCTAssertEqual(HorizontalCollectionConstants.itemSize, 56)
        XCTAssertEqual(HorizontalCollectionConstants.itemSpacing, 16)
        XCTAssertEqual(HorizontalCollectionConstants.selectionAnimationDuration, 0.25)
        XCTAssertEqual(HorizontalCollectionConstants.selectionAnimationDuringDrag, 0.1)
        XCTAssertEqual(HorizontalCollectionConstants.scrollDebounceTime, 0.1)
        XCTAssertTrue(HorizontalCollectionConstants.enableRealTimeSelection)
        XCTAssertEqual(HorizontalCollectionConstants.realTimeSelectionThreshold, 30)
        XCTAssertTrue(HorizontalCollectionConstants.alwaysCenterSelectedItem)
        XCTAssertFalse(HorizontalCollectionConstants.debugMode)
        XCTAssertEqual(HorizontalCollectionConstants.minCorrectionThreshold, 2.0)
        XCTAssertEqual(HorizontalCollectionConstants.maxCorrectionThreshold, 40.0)
        XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .standard)
        XCTAssertTrue(HorizontalCollectionConstants.useSnappingBehavior)
        XCTAssertEqual(HorizontalCollectionConstants.scrollSnapSensitivity, 0.7)
        XCTAssertEqual(HorizontalCollectionConstants.velocityMultiplier, 0.25)
        XCTAssertEqual(HorizontalCollectionConstants.snapStrength, 0.75)
        XCTAssertEqual(HorizontalCollectionConstants.maxItemsToAdvance, 50)
        XCTAssertEqual(HorizontalCollectionConstants.lowVelocityThreshold, 40.0)
        XCTAssertEqual(HorizontalCollectionConstants.mediumVelocityThreshold, 200.0)
        XCTAssertEqual(HorizontalCollectionConstants.highVelocityMultiplier, 0.012)
    }
    
    // Test actor-based configuration
    func testActorBasedConfiguration() async {
        // Store original values
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
        
        // Verify values were updated
        XCTAssertEqual(HorizontalCollectionConstants.itemSize, 100)
        XCTAssertEqual(HorizontalCollectionConstants.itemSpacing, 25)
        XCTAssertTrue(HorizontalCollectionConstants.debugMode)
        XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .targetContentOffset)
        
        // Configure with partial updates
        await HorizontalCollectionConstants.configure(
            itemSize: 75,
            debugMode: false
        )
        
        // Verify partial updates
        XCTAssertEqual(HorizontalCollectionConstants.itemSize, 75)
        XCTAssertEqual(HorizontalCollectionConstants.itemSpacing, 25) // Unchanged from previous config
        XCTAssertFalse(HorizontalCollectionConstants.debugMode)
        XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .targetContentOffset) // Unchanged from previous config
        
        // Reset to original values
        await HorizontalCollectionConstants.configure(
            itemSize: originalItemSize,
            itemSpacing: originalItemSpacing,
            debugMode: originalDebugMode,
            scrollBehaviorMode: originalScrollBehaviorMode
        )
    }
    
    // Test direct property updates
    func testDirectPropertyUpdates() {
        // Store original values
        let originalAnimationDuration = HorizontalCollectionConstants.selectionAnimationDuration
        let originalAnimationDuringDrag = HorizontalCollectionConstants.selectionAnimationDuringDrag
        let originalDebounceTime = HorizontalCollectionConstants.scrollDebounceTime
        
        // Update properties directly
        HorizontalCollectionConstants.selectionAnimationDuration = 0.5
        HorizontalCollectionConstants.selectionAnimationDuringDrag = 0.2
        HorizontalCollectionConstants.scrollDebounceTime = 0.3
        
        // Verify changes
        XCTAssertEqual(HorizontalCollectionConstants.selectionAnimationDuration, 0.5)
        XCTAssertEqual(HorizontalCollectionConstants.selectionAnimationDuringDrag, 0.2)
        XCTAssertEqual(HorizontalCollectionConstants.scrollDebounceTime, 0.3)
        
        // Reset to original values
        HorizontalCollectionConstants.selectionAnimationDuration = originalAnimationDuration
        HorizontalCollectionConstants.selectionAnimationDuringDrag = originalAnimationDuringDrag
        HorizontalCollectionConstants.scrollDebounceTime = originalDebounceTime
    }
    
    // Test screen dimension helpers
    @MainActor
    func testScreenDimensionHelpers() {
        // Test screenWidth property
        let screenWidth = HorizontalCollectionConstants.screenWidth
        
        #if os(iOS)
        // On iOS, should match UIScreen
        XCTAssertEqual(screenWidth, UIScreen.main.bounds.width)
        #else
        // On other platforms, should default to 1080
        XCTAssertEqual(screenWidth, 1080)
        #endif
        
        // Test cornerSpacerWidth (which depends on screenWidth and itemSize)
        let originalItemSize = HorizontalCollectionConstants.itemSize
        HorizontalCollectionConstants.itemSize = 100
        
        let expectedSpacerWidth = (screenWidth - 100) / 2
        XCTAssertEqual(HorizontalCollectionConstants.cornerSpacerWidth, expectedSpacerWidth)
        
        // Reset to original value
        HorizontalCollectionConstants.itemSize = originalItemSize
    }
    
    // Test concurrency safety
    func testConcurrencySafety() async {
        // Store original values
        let originalItemSize = HorizontalCollectionConstants.itemSize
        let originalItemSpacing = HorizontalCollectionConstants.itemSpacing
        
        // Launch many concurrent configuration requests
        await withTaskGroup(of: Void.self) { group in
            for i in 1...20 {
                group.addTask {
                    // Alternate between different configurations
                    let size = 50 + CGFloat(i * 2)
                    let spacing = 10 + CGFloat(i)
                    
                    await HorizontalCollectionConstants.configure(
                        itemSize: size,
                        itemSpacing: spacing
                    )
                    
                    // Small delay to increase chance of concurrency issues
                    try? await Task.sleep(nanoseconds: 10_000_000)
                }
            }
        }
        
        // Values should be consistently set to the last task that ran
        // Just verify they're sensible values within our test ranges
        XCTAssertGreaterThanOrEqual(HorizontalCollectionConstants.itemSize, 50)
        XCTAssertLessThanOrEqual(HorizontalCollectionConstants.itemSize, 90)
        XCTAssertGreaterThanOrEqual(HorizontalCollectionConstants.itemSpacing, 10)
        XCTAssertLessThanOrEqual(HorizontalCollectionConstants.itemSpacing, 30)
        
        // Reset to original values
        await HorizontalCollectionConstants.configure(
            itemSize: originalItemSize,
            itemSpacing: originalItemSpacing
        )
    }
    
    // Test scroll behavior mode enum
    func testScrollBehaviorModeEnum() {
        // Test the available modes
        let standardMode = ScrollBehaviorMode.standard
        let targetContentOffsetMode = ScrollBehaviorMode.targetContentOffset
        
        // Verify distinctness
        XCTAssertNotEqual(standardMode, targetContentOffsetMode)
        
        // Store original mode
        let originalMode = HorizontalCollectionConstants.scrollBehaviorMode
        
        // Set to standard mode
        HorizontalCollectionConstants.scrollBehaviorMode = .standard
        XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .standard)
        
        // Set to target content offset mode
        HorizontalCollectionConstants.scrollBehaviorMode = .targetContentOffset
        XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .targetContentOffset)
        
        // Reset to original mode
        HorizontalCollectionConstants.scrollBehaviorMode = originalMode
    }
    
    // Test actor isolation properties
    func testActorIsolationProperties() async {
        // Test that actor properties can be accessed from async context
        let itemSize = await Task {
            HorizontalCollectionConstants.itemSize
        }.value
        
        XCTAssertEqual(itemSize, HorizontalCollectionConstants.itemSize)
        
        // Test concurrent read-write access
        await withTaskGroup(of: Void.self) { group in
            for _ in 1...10 {
                group.addTask {
                    // Read values
                    let _ = HorizontalCollectionConstants.itemSize
                    let _ = HorizontalCollectionConstants.itemSpacing
                    
                    // Write values (within the actor)
                    await HorizontalCollectionConstants.configure(
                        itemSize: Double.random(in: 50...80),
                        itemSpacing: Double.random(in: 10...20)
                    )
                }
            }
        }
        
        // If we reached here without deadlock or race conditions, test passes
    }
    
    // Test debug mode impact
    func testDebugModeImpact() {
        // Store original debug mode
        let originalDebugMode = HorizontalCollectionConstants.debugMode
        
        // Test with debug mode off
        HorizontalCollectionConstants.debugMode = false
        // Debug prints should not occur, but we can't directly test this in a unit test
        
        // Test with debug mode on
        HorizontalCollectionConstants.debugMode = true
        // Debug prints should appear, but we can't directly test output in a unit test
        
        // Reset to original value
        HorizontalCollectionConstants.debugMode = originalDebugMode
    }
}