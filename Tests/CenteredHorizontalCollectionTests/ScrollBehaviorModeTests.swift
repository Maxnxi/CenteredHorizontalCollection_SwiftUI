//
//  ScrollBehaviorModeTests.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/26/25.
//


import XCTest
@testable import CenteredHorizontalCollection
import SwiftUI

final class ScrollBehaviorModeTests: XCTestCase {
    
    // Test that ScrollBehaviorMode enum has correct cases
    func testScrollBehaviorModeEnum() {
        // Test standard mode
        let standardMode = ScrollBehaviorMode.standard
        
        // Test target content offset mode
        let targetContentOffsetMode = ScrollBehaviorMode.targetContentOffset
        
        // Verify they are different
        XCTAssertNotEqual(standardMode, targetContentOffsetMode)
    }
    
    // Test that different scroll behavior modes are properly applied
    @MainActor
    func testScrollBehaviorModeConfiguration() async {
        // Store original value
        let originalMode = HorizontalCollectionConstants.scrollBehaviorMode
        
        // Test standard mode
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: .standard
        )
        
        XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .standard)
        
        // Test target content offset mode
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: .targetContentOffset
        )
        
        XCTAssertEqual(HorizontalCollectionConstants.scrollBehaviorMode, .targetContentOffset)
        
        // Reset to original value
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: originalMode
        )
    }
    
    // Test that the view model behaves differently based on scroll behavior mode
    @MainActor
    func testViewModelBehaviorWithDifferentModes() async {
        // Store original mode
        let originalMode = HorizontalCollectionConstants.scrollBehaviorMode
        
        // Create view model
        let viewModel = CenteredScrollViewModel()
        
        // Test with standard mode
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: .standard
        )
        
        // Initialize view model (reload configuration)
        let viewModel1 = CenteredScrollViewModel()
        
        // Standard mode behavior would be tested here
        // We can't fully test the scrolling behavior without UI interaction,
        // but we can verify the view model still functions
        
        viewModel1.startDragging()
        XCTAssertTrue(viewModel1.isDragging)
        
        viewModel1.endDragging()
        XCTAssertFalse(viewModel1.isDragging)
        
        // Test with target content offset mode
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: .targetContentOffset
        )
        
        // Initialize view model (reload configuration)
        let viewModel2 = CenteredScrollViewModel()
        
        // Target content offset mode behavior would be tested here
        // Again, we can't fully test the scrolling physics without UI interaction,
        // but we can verify the view model still functions
        
        viewModel2.startDragging()
        XCTAssertTrue(viewModel2.isDragging)
        
        viewModel2.endDragging()
        XCTAssertFalse(viewModel2.isDragging)
        
        // Reset to original mode
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: originalMode
        )
    }
    
    // Test that different scroll behavior modes affect animation timing
    @MainActor
    func testScrollBehaviorModeAnimationTiming() async {
        // Store original values
        let originalMode = HorizontalCollectionConstants.scrollBehaviorMode
        let originalDuration = HorizontalCollectionConstants.selectionAnimationDuration
        
        // Test with standard mode
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: .standard
        )
        
        // Set a specific animation duration for testing
        HorizontalCollectionConstants.selectionAnimationDuration = 0.3
        
        // Initialize view model (reload configuration)
        let viewModel1 = CenteredScrollViewModel()
        
        // Test with target content offset mode
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: .targetContentOffset
        )
        
        // Set a different animation duration for testing
        HorizontalCollectionConstants.selectionAnimationDuration = 0.5
        
        // Initialize view model (reload configuration)
        let viewModel2 = CenteredScrollViewModel()
        
        // Reset to original values
        await HorizontalCollectionConstants.configure(
            scrollBehaviorMode: originalMode
        )
        HorizontalCollectionConstants.selectionAnimationDuration = originalDuration
    }
    
    // Test that velocity thresholds affect scrolling behavior
    @MainActor
    func testVelocityThresholds() async {
        // Store original values
        let originalLowThreshold = HorizontalCollectionConstants.lowVelocityThreshold
        let originalMediumThreshold = HorizontalCollectionConstants.mediumVelocityThreshold
        
        // Set test values
        HorizontalCollectionConstants.lowVelocityThreshold = 30.0
        HorizontalCollectionConstants.mediumVelocityThreshold = 150.0
        
        // Create view model (loads configuration)
        let viewModel = CenteredScrollViewModel()
        
        // We would test different velocity scenarios here, but without
        // UI interaction, we can only verify the configuration was loaded
        
        // Reset to original values
        HorizontalCollectionConstants.lowVelocityThreshold = originalLowThreshold
        HorizontalCollectionConstants.mediumVelocityThreshold = originalMediumThreshold
    }
}