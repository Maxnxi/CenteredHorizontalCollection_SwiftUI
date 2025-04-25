//
//  CenteredHorizontalCollectionPerformanceTests.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/26/25.
//


import XCTest
@testable import CenteredHorizontalCollection
import SwiftUI

final class CenteredHorizontalCollectionPerformanceTests: XCTestCase {
    
    // Test performance with various item counts
    func testPerformanceWithIncreasingItems() {
        // Small collection (10 items)
        measure {
            let items = createTestItems(count: 10)
            let _ = CenteredHorizontalCollection(items: items) { item, isSelected in
                Text("\(item.id)")
            }
        }
        
        // Medium collection (50 items)
        measure {
            let items = createTestItems(count: 50)
            let _ = CenteredHorizontalCollection(items: items) { item, isSelected in
                Text("\(item.id)")
            }
        }
        
        // Large collection (100 items)
        measure {
            let items = createTestItems(count: 100)
            let _ = CenteredHorizontalCollection(items: items) { item, isSelected in
                Text("\(item.id)")
            }
        }
    }
    
    // Test performance of calculating offsets
    func testOffsetCalculationPerformance() {
        let viewModel = CenteredScrollViewModel()
        
        // Create a large offset dictionary to simulate many items
        var largeOffsetsDict: [Int: CGFloat] = [:]
        for i in 1...1000 {
            largeOffsetsDict[i] = CGFloat(i * 10)
        }
        
        // Measure update performance
        measure {
            viewModel.updateOffsets(largeOffsetsDict)
        }
    }
    
    // Test performance of selection changes
    func testSelectionChangePerformance() {
        let viewModel = CenteredScrollViewModel()
        
        // Set up with many offsets
        var largeOffsetsDict: [Int: CGFloat] = [:]
        for i in 1...100 {
            largeOffsetsDict[i] = CGFloat(i * 10)
        }
        viewModel.updateOffsets(largeOffsetsDict)
        
        // Measure performance of selection changes
        measure {
            for i in 1...20 {
                viewModel.selectItem(i * 5) // Select every 5th item
            }
        }
    }
    
    // Test performance of drag operations
    func testDragOperationPerformance() {
        let viewModel = CenteredScrollViewModel()
        
        // Measure performance of drag operations
        measure {
            for _ in 1...100 {
                viewModel.startDragging()
                viewModel.endDragging()
            }
        }
    }
    
    // Test performance of HorizontalCollectionConstants actor operations
    func testConstantsActorPerformance() async {
        // Measure the performance of async actor operations
        let iterations = 100
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 1...iterations {
            await HorizontalCollectionConstants.configure(
                itemSize: Double.random(in: 40...120),
                itemSpacing: Double.random(in: 10...30)
            )
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let timePerOperation = (endTime - startTime) / Double(iterations)
        
        // Log performance data
        print("Average time per actor operation: \(timePerOperation * 1000) ms")
        
        // Reset to default values
        await HorizontalCollectionConstants.configure(
            itemSize: 56,
            itemSpacing: 16
        )
    }
    
    // Test performance with complex item views
    func testComplexItemViewPerformance() {
        let items = createTestItems(count: 20)
        
        // Measure with simple item views
        measure {
            let _ = CenteredHorizontalCollection(items: items) { item, isSelected in
                Text("\(item.id)")
            }
        }
        
        // Measure with complex item views
        measure {
            let _ = CenteredHorizontalCollection(items: items) { item, isSelected in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.color)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white, lineWidth: 2)
                                .padding(3)
                        )
                    
                    VStack {
                        Text("Item")
                            .font(.headline)
                        Text("\(item.id)")
                            .font(.title)
                        Text("Subtext")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }
                .shadow(radius: isSelected ? 6 : 2)
                .scaleEffect(isSelected ? 1.1 : 0.9)
                .rotation3DEffect(
                    isSelected ? .degrees(0) : .degrees(-5),
                    axis: (x: 0, y: 1, z: 0)
                )
            }
        }
    }
    
    // Test memory usage with different collection sizes
    func testMemoryUsage() {
        // This is a basic approach to memory testing
        // For more accurate memory testing, use Instruments
        
        // Create progressively larger collections and measure allocations
        autoreleasepool {
            var collections: [Any] = []
            
            for size in [10, 50, 100, 500, 1000] {
                let items = createTestItems(count: size)
                let collection = CenteredHorizontalCollection(items: items) { item, isSelected in
                    Text("\(item.id)")
                }
                collections.append(collection)
                
                // Log memory usage if available
                if let memoryUsage = memoryUsageInMB() {
                    print("Memory usage with \(size) items: \(memoryUsage) MB")
                }
            }
            
            // Clear collections
            collections.removeAll()
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestItems(count: Int) -> [Item] {
        return (1...count).map { Item(id: $0, color: .blue) }
    }
    
    private func memoryUsageInMB() -> Double? {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &taskInfo) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (intPtr: UnsafeMutablePointer<integer_t>) in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            return Double(taskInfo.phys_footprint) / (1024 * 1024)
        } else {
            return nil
        }
    }
}