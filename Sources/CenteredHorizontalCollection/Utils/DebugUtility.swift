//
//  for.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/25/25.
//


import Foundation

/// Utility class for debug printing with consistent formatting
/// This helps to easily filter debug logs
class DebugUtility {
    /// Categories for different types of debug messages
    enum Category: String {
        case offset = "OFFSET"
        case selection = "SELECTION"
        case timer = "TIMER"
        case correction = "CORRECTION"
        case interaction = "INTERACTION"
        case general = "GENERAL"
    }
    
    /// Main debug print function that only prints when debug mode is enabled
    static func debugPrint(_ category: Category, _ message: String, file: String = #file, line: Int = #line) {
        guard HorizontalCollectionConstants.debugMode else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("🔍 [\(category.rawValue)] [\(fileName):\(line)] \(message)")
    }
    
    /// Special debug print for offset values
    static func logOffset(id: Int, offset: CGFloat, file: String = #file, line: Int = #line) {
        guard HorizontalCollectionConstants.debugMode else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("📏 [OFFSET] [\(fileName):\(line)] Item \(id): \(String(format: "%.2f", offset))")
    }
    
    /// Debug print for selection changes
    static func logSelectionChange(from oldID: Int, to newID: Int, file: String = #file, line: Int = #line) {
        guard HorizontalCollectionConstants.debugMode else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("🔄 [SELECTION] [\(fileName):\(line)] Changed from \(oldID) to \(newID)")
    }
    
    /// Debug print for correction decisions
    static func logCorrectionDecision(id: Int, offset: CGFloat, needsCorrection: Bool, forceCorrection: Bool = false, file: String = #file, line: Int = #line) {
        guard HorizontalCollectionConstants.debugMode else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("🎯 [CORRECTION] [\(fileName):\(line)] Item \(id) offset: \(String(format: "%.2f", offset)) - Needs correction: \(needsCorrection) - forceCorrection: \(forceCorrection)")
    }
    
    /// Debug print for drag events
    static func logDragEvent(isDragging: Bool, file: String = #file, line: Int = #line) {
        guard HorizontalCollectionConstants.debugMode else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("👆 [INTERACTION] [\(fileName):\(line)] Dragging: \(isDragging)")
    }
    
    /// Debug print for timer events
    static func logTimerEvent(action: String, file: String = #file, line: Int = #line) {
        guard HorizontalCollectionConstants.debugMode else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        print("⏱️ [TIMER] [\(fileName):\(line)] \(action)")
    }
}