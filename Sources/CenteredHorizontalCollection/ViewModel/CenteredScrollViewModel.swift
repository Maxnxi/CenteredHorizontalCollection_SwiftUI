//
//  CenteredScrollViewModel.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/25/25.
//
import Foundation
import SwiftUI
import Combine

/// ViewModel to handle scroll logic for centered collection
@MainActor
class CenteredScrollViewModel: ObservableObject {
	// MARK: - Published Properties
	
	/// Currently selected item ID
	@Published var selectedID: Int = 1
	
	/// Indicates if the user is currently dragging the collection
	@Published var isDragging: Bool = false
	
	/// Indicates if the item was manually selected (vs auto-selection)
	@Published var isManuallySelected: Bool = false
	
	// MARK: - Private Constants
	
	// Configuration constants
	private var selectionAnimationDuration: Double = 0.25
	private var selectionAnimationDuringDrag: Double = 0.1
	private var scrollDebounceTime: Double = 0.1
	private var minCorrectionThreshold: CGFloat = 2.0
	private var maxCorrectionThreshold: CGFloat = 40.0
	private var useSnappingBehavior: Bool = true
	private var realTimeSelectionThreshold: CGFloat = 30
	private var lowVelocityThreshold: CGFloat = 40.0
	private var mediumVelocityThreshold: CGFloat = 200.0
	private var maxItemsToAdvance: Int = 50
	
	// Correction limiting
	private let maxCorrectionAttempts = 3
	private let correctionCooldownTime: TimeInterval = 1.0
	
	// MARK: - Private Properties
	
	// External selection binding
	private var externalSelection: Binding<Int>?
	
	// Scroll mode
	private var usingTargetContentOffsetMode = false
	
	// Internal state
	private var currentOffsets: [Int: CGFloat] = [:]
	private var scrollDebounceTimer: Timer?
	private var scrollViewReader: ScrollViewProxy?
	private var scrollVelocity: CGFloat = 0.0
	private var lastContentOffset: CGFloat = 0.0
	private var timestamp: TimeInterval = 0.0
	private var lastDragDirection: Int = 0
	
	// Momentum tracking
	private var isInMomentumScroll: Bool = false
	private var momentumScrollTimer: Timer?
	private var lastScrollTime: Date = Date()
	
	// Targeting state
	private var lastPredictedTargetID: Int?
	private var dragEndTimestamp: Date?
	
	// Correction tracking
	private var lastCorrectionTime: Date?
	private var correctionCounter = 0
	
	private var momentumScrollTask: Task<(), Never>?
	
	private var cancellables = Set<AnyCancellable>()
	
	// MARK: - Initialization
	
	init() {
		debugLog("CenteredScrollViewModel initialized")
		loadConfiguration()
	}
	
	// MARK: - Public Methods
	
	/// Bind to an external selection value
	/// - Parameter binding: The binding to sync with
	func bindToExternalSelection(_ binding: Binding<Int>) {
		self.externalSelection = binding
		self.selectedID = binding.wrappedValue
		
		// Set up a publisher to watch for selectedID changes
		$selectedID
			.sink { [weak self] newValue in
				guard let self = self else { return }
				// Only update if values don't match to avoid cycles
				if self.externalSelection?.wrappedValue != newValue {
					self.externalSelection?.wrappedValue = newValue
					debugLog("Updated external binding to \(newValue)")
				}
			}
			.store(in: &cancellables)
		
	}
	
	/// Set the scroll view reader for controlling scroll position
	/// - Parameters:
	///   - proxy: The scroll view proxy
	///   - scrollAfterAppear: Whether to animate the initial scroll
	@MainActor
	func setScrollViewReader(_ proxy: ScrollViewProxy, scrollAfterAppear: Bool = false) {
		self.scrollViewReader = proxy
		debugLog("ScrollViewReader set")
		
		// Reset correction tracking
		lastCorrectionTime = nil
		correctionCounter = 0
		
		if scrollAfterAppear {
			// Animate the initial scroll
			debugLog("Initial scroll after Appear")
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				withAnimation {
					proxy.scrollTo(self.selectedID, anchor: .center)
				}
			}
		} else {
			// Immediate scroll without animation
			debugLog("Initial scroll without visual effect")
			proxy.scrollTo(self.selectedID, anchor: .center)
		}
		
		debugLog("Initial scroll to item \(self.selectedID)")
	}
	
	/// Calculate offset from center for each cell
	/// - Parameter geo: The geometry proxy for the item
	/// - Returns: The offset from center
	@MainActor
	func computeOffset(geo: GeometryProxy) -> CGFloat {
		// Calculate global center position
		let globalCenter = geo.frame(in: .global).midX
		
		// Get offset from screen center
		let offset = globalCenter - HorizontalCollectionConstants.screenWidth / 2
		
		// Update velocity tracking
		updateScrollVelocity(currentOffset: globalCenter)
		
		return offset
	}
	
	/// Handle preference change with updated offsets
	/// - Parameter offsets: Dictionary of item IDs to their offsets
	@MainActor
	func updateOffsets(_ offsets: [Int: CGFloat]) {
		// Store current offsets
		self.currentOffsets = offsets
		
		// Log offsets for debugging
		logOffsets(offsets)
		
		// Determine if we should apply correction
		let shouldApplyCorrection = !isDragging && !(isInMomentumScroll && !usingTargetContentOffsetMode)
		
		// Update selection based on closest item
		updateSelection(applyCorrection: shouldApplyCorrection)
		
		if isDragging {
			debugLog("Real-time selection update during drag")
		}
	}
	
	/// Handle drag start
	func startDragging() {
		isDragging = true
		debugLog("Dragging started: true")
		
		// Cancel any pending timers
		scrollDebounceTimer?.invalidate()
		momentumScrollTimer?.invalidate()
		isInMomentumScroll = false
		
		debugLog("Timer invalidated on drag start")
		
		// Reset velocity measurement
		timestamp = Date().timeIntervalSince1970
		
		debugLog("Enabling real-time selection during drag")
	}
	
	/// Handle drag end
	@MainActor
	func endDragging() {
		// Cancel any existing debounce timer
		scrollDebounceTimer?.invalidate()
		
		// Handle differently based on scroll mode
		if usingTargetContentOffsetMode {
			// For enhanced scrolling, use targetContentOffset behavior
			isDragging = false
			debugLog("Dragging ended: false")
			
			// Apply improved targeting
			applyImprovedTargetContentOffsetBehavior()
			
			// Reset prediction state
			lastPredictedTargetID = nil
			
			debugLog("Applied improved targetContentOffset without debounce")
		} else {
			// For standard mode with momentum support
			
			// Reset correction tracking
			lastCorrectionTime = nil
			correctionCounter = 0
			
			// Capture velocity for accurate predictions
			let finalVelocity = scrollVelocity
			
			// Update dragging state
			isDragging = false
			debugLog("Dragging ended: false")
			
			// Handle based on velocity
			if abs(finalVelocity) > lowVelocityThreshold {
				// For significant velocity, track momentum
				startMomentumScrollTracking()
				debugLog("Allowing momentum to continue without immediate correction")
			} else {
				// For low velocity, center immediately
				debugLog("Setting short debounce timer for low velocity")
				
				
				// In endDragging, use this method
				scrollDebounceTimer = Timer.scheduledTimer(
					withTimeInterval: scrollDebounceTime,
					repeats: false
				) { [weak self] _ in
					guard let self = self else { return }
					
					Task { @MainActor in
						self.handleDebounceTimer(finalVelocity: finalVelocity)
					}
				}
			}
		}
	}
	
	// Define a MainActor method for the timer to call
	@MainActor
	private func handleDebounceTimer(finalVelocity: CGFloat) {
		debugLog("Debounce timer fired")
		
		// Use captured velocity if it's higher
		if abs(self.scrollVelocity) < abs(finalVelocity) {
			debugLog("Using drag-end velocity for prediction: \(finalVelocity)")
			self.scrollVelocity = finalVelocity
		}
		
		// Apply centering
		updateSelection(applyCorrection: true, forceCorrection: true)
		
		debugLog("Final adjustment applied after drag")
	}
	
	/// Manually select an item
	/// - Parameter itemID: The ID of the item to select
	func selectItem(_ itemID: Int) {
		let oldID = selectedID
		selectedID = itemID
		isManuallySelected = true
		
		// Update external binding if available
		updateExternalBinding(itemID)
		
		debugLog("Manual selection changed from \(oldID) to \(itemID)")
		
		// Scroll to the item
		scrollToItem(itemID)
	}
	
	/// Navigate to previous item
	func selectPreviousItem() {
		// Find minimum ID
		let minID = currentOffsets.keys.min() ?? 1
		let oldID = selectedID
		let newID = max(minID, selectedID - 1)
		
		if oldID != newID {
			selectedID = newID
			
			// Update external binding if available
			updateExternalBinding(newID)
			
			debugLog("Selection changed from \(oldID) to \(newID) (previous)")
			
			// Scroll to the item
			scrollToItem(newID)
		}
	}
	
	/// Navigate to next item
	func selectNextItem() {
		// Find maximum ID
		let maxID = currentOffsets.keys.max() ?? 1
		let oldID = selectedID
		let newID = min(maxID, selectedID + 1)
		
		if oldID != newID {
			selectedID = newID
			
			// Update external binding if available
			updateExternalBinding(newID)
			
			debugLog("Selection changed from \(oldID) to \(newID) (next)")
			
			// Scroll to the item
			scrollToItem(newID)
		}
	}
	
	/// Update selection based on closest item
	/// - Parameters:
	///   - applyCorrection: Whether to apply centering correction
	///   - forceCorrection: Whether to force correction regardless of thresholds
	@MainActor
	func updateSelection(applyCorrection: Bool = true, forceCorrection: Bool = false) {
		// Find the closest item to center
		guard let closestID = findClosestItemToCenter() else { return }
		
		// Handle manual selection override
		if isManuallySelected && !isDragging {
			if selectedID != closestID {
				debugLog("Ignoring auto-selection due to manual selection")
				return
			} else {
				debugLog("Manual selection matches closest item, resuming auto-selection")
				isManuallySelected = false
			}
		}
		
		if isDragging {
			// During dragging, update selection visually but don't center
			if selectedID != closestID {
				let oldID = selectedID
				
				// Animate selection change
				withAnimation(.easeInOut(duration: selectionAnimationDuringDrag)) {
					selectedID = closestID
					updateExternalBinding(closestID)
				}
				
				debugLog("Selection changed from \(oldID) to \(closestID) during drag")
			}
		} else {
			// Not dragging - update selection and center item
			if selectedID != closestID {
				let oldID = selectedID
				selectedID = closestID
				updateExternalBinding(closestID)
				
				debugLog("Selection changed from \(oldID) to \(closestID)")
				
				// Center the item unless in momentum scroll
				if !isInMomentumScroll || usingTargetContentOffsetMode {
					withAnimation(.easeInOut(duration: selectionAnimationDuration)) {
						scrollViewReader?.scrollTo(closestID, anchor: .center)
					}
				} else {
					debugLog("Skipping centering during momentum scroll")
				}
			} else if applyCorrection && (!isInMomentumScroll || forceCorrection) {
				// Item is already selected, but may need centering
				if isInMomentumScroll && !forceCorrection {
					debugLog("Skipping correction during momentum scroll")
				} else {
					correctOffsetIfNeeded(forceCorrection: forceCorrection)
				}
			}
		}
	}
	
	// MARK: - Private Methods
	
	/// Load configuration from actor
	private func loadConfiguration() {
		// Try to load constants from the actor
		selectionAnimationDuration = HorizontalCollectionConstants.selectionAnimationDuration
		selectionAnimationDuringDrag = HorizontalCollectionConstants.selectionAnimationDuringDrag
		scrollDebounceTime = HorizontalCollectionConstants.scrollDebounceTime
		minCorrectionThreshold = HorizontalCollectionConstants.minCorrectionThreshold
		maxCorrectionThreshold = HorizontalCollectionConstants.maxCorrectionThreshold
		useSnappingBehavior = HorizontalCollectionConstants.useSnappingBehavior
		realTimeSelectionThreshold = HorizontalCollectionConstants.realTimeSelectionThreshold
		lowVelocityThreshold = HorizontalCollectionConstants.lowVelocityThreshold
		mediumVelocityThreshold = HorizontalCollectionConstants.mediumVelocityThreshold
		maxItemsToAdvance = HorizontalCollectionConstants.maxItemsToAdvance
		
		// Check scroll behavior mode
		let mode = HorizontalCollectionConstants.scrollBehaviorMode
		usingTargetContentOffsetMode = (mode == .targetContentOffset)
		
		debugLog("Configuration loaded successfully")
	}
	
	/// Update external binding if available
	/// - Parameter newID: The new ID to set
	private func updateExternalBinding(_ newID: Int) {
		if let externalSelection = externalSelection {
			externalSelection.wrappedValue = newID
		}
	}
	
	/// Log debug message if debug mode is enabled
	/// - Parameter message: The message to log
	private func debugLog(_ message: String) {
		if HorizontalCollectionConstants.debugMode {
			print("🔍 [VIEWMODEL] \(message)")
		}
	}
	
	/// Log offsets for debugging
	/// - Parameter offsets: The offsets to log
	private func logOffsets(_ offsets: [Int: CGFloat]) {
		if HorizontalCollectionConstants.debugMode {
			offsets.forEach { id, offset in
				print("📏 [OFFSET] Item \(id): \(String(format: "%.2f", offset))")
			}
		}
	}
	
	/// Update scroll velocity tracking
	/// - Parameter currentOffset: The current content offset
	private func updateScrollVelocity(currentOffset: CGFloat) {
		let currentTime = Date().timeIntervalSince1970
		let elapsed = currentTime - timestamp
		
		guard elapsed > 0 else { return }
		
		// Calculate movement since last update
		let delta = currentOffset - lastContentOffset
		
		// Track significant movement
		if abs(delta) > 1.0 {
			// Record drag direction for later use
			lastDragDirection = delta > 0 ? 1 : -1
			debugLog("Drag direction: \(lastDragDirection > 0 ? "right" : "left")")
			
			// Update tracking timestamps
			lastScrollTime = Date()
			
			// Detect momentum without explicit drag
			if abs(delta) > 5.0 && !isDragging {
				startMomentumScrollTracking()
			}
		}
		
		// Calculate instantaneous velocity
		let instantVelocity = delta / CGFloat(elapsed)
		
		// Apply smoothing for more natural feel
		if abs(scrollVelocity) > 0.01 {
			// Prioritize previous velocity for inertia effect
			scrollVelocity = scrollVelocity * 0.8 + instantVelocity * 0.2
		} else {
			scrollVelocity = instantVelocity
		}
		
		// Clamp velocity to prevent extreme values
		let maxVelocity: CGFloat = 5000.0
		if abs(scrollVelocity) > maxVelocity {
			scrollVelocity = scrollVelocity > 0 ? maxVelocity : -maxVelocity
		}
		
		debugLog("Scroll velocity: \(String(format: "%.2f", scrollVelocity))")
		
		// Update tracking values
		lastContentOffset = currentOffset
		timestamp = currentTime
	}
	
	/// Start tracking momentum scroll to prevent interruptions
	private func startMomentumScrollTracking() {
		// Cancel any existing momentum timer
		momentumScrollTimer?.invalidate()
		
		// Mark that we're in momentum scroll
		isInMomentumScroll = true
		debugLog("Started momentum scroll tracking")
		
		// Create a new task for monitoring scroll stopping
		let task = Task { [weak self] in
			// Keep checking until cancelled
			while !Task.isCancelled {
				// Delay between checks
				try? await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
				
				guard let self = self else { break }
				
				// Safely access main actor state
				let shouldEndMomentum = await MainActor.run {
					let timeElapsed = Date().timeIntervalSince(self.lastScrollTime)
					return timeElapsed > 0.3
				}
				
				// If no movement for 300ms, assume scrolling stopped
				if shouldEndMomentum {
					await MainActor.run {
						self.endMomentumScrollTracking()
					}
					break
				}
			}
		}
		
		// Store the task in a way you can cancel it later
		// You'll need to add a property to the class to store this
		momentumScrollTask = task
	}
	
	/// End momentum scroll tracking
	private func endMomentumScrollTracking() {
		momentumScrollTimer?.invalidate()
		momentumScrollTimer = nil
		isInMomentumScroll = false
		debugLog("Ended momentum scroll tracking")
		
		// Apply final correction when momentum ends
		if !isDragging {
			let isStandardMode = !usingTargetContentOffsetMode
			if isStandardMode {
				// Capture relevant state locally to avoid capturing self
				let isDraggingNow = isDragging
				
				Task { @MainActor in
					// Add a small delay
					try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
					
					// Self is safely accessed on the main actor
					if !self.isDragging && !isDraggingNow {
						self.updateSelection(applyCorrection: true, forceCorrection: true)
					}
				}
			}
		}
	}
	
	/// Find which item is closest to center
	/// - Returns: The ID of the closest item
	private func findClosestItemToCenter() -> Int? {
		// Find item with minimum absolute offset
		let result = currentOffsets.min(by: { abs($0.value) < abs($1.value) })?.key
		
		// Log for debugging
		if let id = result, let offset = currentOffsets[id] {
			if isDragging && useSnappingBehavior {
				if abs(offset) < realTimeSelectionThreshold {
					debugLog("Closest item to center: \(id) with offset: \(String(format: "%.2f", offset))")
				}
			} else {
				debugLog("Closest item to center: \(id) with offset: \(String(format: "%.2f", offset))")
			}
		}
		
		return result
	}
	
	/// Find the item that is exactly closest to center
	/// - Returns: The ID of the closest item
	private func findItemClosestToExactCenter() -> Int? {
		return currentOffsets.min(by: { abs($0.value) < abs($1.value) })?.key
	}
	
	/// Scroll to a specific item with animation
	/// - Parameter itemID: The ID of the item to scroll to
	private func scrollToItem(_ itemID: Int) {
		withAnimation(.easeInOut(duration: selectionAnimationDuration)) {
			scrollViewReader?.scrollTo(itemID, anchor: .center)
			debugLog("Scrolling to item \(itemID)")
		}
	}
	
	/// Correct slight offsets to ensure perfect centering
	/// - Parameter forceCorrection: Whether to force correction regardless of thresholds
	@MainActor
	private func correctOffsetIfNeeded(forceCorrection: Bool = false) {
		// Skip during momentum in standard mode unless forced
		if isInMomentumScroll && !usingTargetContentOffsetMode && !forceCorrection {
			debugLog("Skipping correction during momentum scroll")
			return
		}
		
		// Only proceed if we have a selectedID and offsets
		guard let currentOffset = currentOffsets[selectedID] else { return }
		
		// If another item is now closer, select it instead (for force correction)
		if let closestID = findClosestItemToCenter(),
		   closestID != selectedID,
		   forceCorrection {
			debugLog("Force correction: Updating selection from \(selectedID) to closest item \(closestID)")
			selectedID = closestID
			updateExternalBinding(closestID)
			
			// Center the new selection
			DispatchQueue.main.async {
				withAnimation(.easeInOut(duration: self.selectionAnimationDuration)) {
					self.scrollViewReader?.scrollTo(self.selectedID, anchor: .center)
				}
			}
			return
		}
		
		// Check if we should skip correction
		let shouldSkipDueToCooldown = lastCorrectionTime != nil &&
			Date().timeIntervalSince(lastCorrectionTime!) < correctionCooldownTime
		
		let shouldSkipDueToMaxAttempts = correctionCounter >= maxCorrectionAttempts
		
		// Determine if offset needs correction
		let absOffset = abs(currentOffset)
		let offsetNeedsCorrection = forceCorrection ?
			(absOffset > minCorrectionThreshold && absOffset < maxCorrectionThreshold * 1.5) :
			(absOffset > minCorrectionThreshold && absOffset < maxCorrectionThreshold)
		
		// Final decision incorporating all factors
		let needsCorrection = offsetNeedsCorrection &&
			!shouldSkipDueToCooldown &&
			!shouldSkipDueToMaxAttempts
		
		debugLog("Item \(selectedID) offset: \(String(format: "%.2f", currentOffset)) - Needs correction: \(needsCorrection) - forceCorrection: \(forceCorrection)")
		
		// Log reasons for skipping
		if shouldSkipDueToCooldown {
			debugLog("Skipping correction: in cooldown period")
		}
		
		if shouldSkipDueToMaxAttempts {
			debugLog("Skipping correction: max attempts (\(maxCorrectionAttempts)) reached")
		}
		
		if needsCorrection {
			// Apply correction
			DispatchQueue.main.async {
				self.debugLog("Applying correction to center item \(self.selectedID) (attempt \(self.correctionCounter + 1))")
				
				// Update tracking counters
				self.lastCorrectionTime = Date()
				self.correctionCounter += 1
				
				// Center the item
				withAnimation(.easeInOut(duration: self.selectionAnimationDuration)) {
					self.scrollViewReader?.scrollTo(self.selectedID, anchor: .center)
				}
			}
		} else if abs(currentOffset) <= minCorrectionThreshold {
			// Item is already well-centered, reset counter
			debugLog("Item centered successfully, resetting correction counter")
			correctionCounter = 0
		}
	}
	
	/// Apply enhanced scrolling behavior similar to UICollectionView's targetContentOffset
	@MainActor
	private func applyImprovedTargetContentOffsetBehavior() {
		// Find the item currently closest to center
		guard let currentItemID = findClosestItemToCenter(),
			  let currentOffset = currentOffsets[currentItemID] else {
			// Fallback to standard behavior if we can't determine closest item
			updateSelection(applyCorrection: true, forceCorrection: true)
			return
		}
		
		debugLog("Current closest item: \(currentItemID) with offset: \(currentOffset)")
		
		// Get bounds for safety
		let minItemID = currentOffsets.keys.min() ?? 1
		let maxItemID = currentOffsets.keys.max() ?? 1
		
		// Calculate velocity and direction
		let absVelocity = abs(scrollVelocity)
		debugLog("Raw velocity: \(scrollVelocity), Absolute velocity: \(absVelocity)")
		
		// Determine direction - in SwiftUI, positive velocity means scrolling right to left
		var direction = scrollVelocity > 0 ? -1 : 1
		
		// Special case: very low velocity between items
		if absVelocity < lowVelocityThreshold * 0.5 && abs(currentOffset) > minCorrectionThreshold * 2 {
			if lastDragDirection != 0 {
				// Use last drag direction for better feel
				let directionFromLastDrag = lastDragDirection > 0 ? -1 : 1
				direction = directionFromLastDrag
				debugLog("Between items case - using last drag direction: \(direction)")
			} else {
				// Fallback to offset direction
				direction = currentOffset > 0 ? 1 : -1
				debugLog("Between items case - using offset direction: \(direction)")
			}
		}
		
		debugLog("Scroll direction: \(direction > 0 ? "Right (increasing items)" : "Left (decreasing items)")")
		
		// Determine how many items to move
		var itemsToMove: Int
		
		if absVelocity < lowVelocityThreshold {
			// Low velocity - stay or move just one item
			if abs(currentOffset) > minCorrectionThreshold * 2 {
				itemsToMove = 1 // Between items, move one
				debugLog("Low velocity but between items, moving 1 item in direction: \(direction)")
			} else {
				itemsToMove = 0 // Well-centered, stay
				debugLog("Low velocity (\(absVelocity)), staying on current item")
			}
		} else if absVelocity < mediumVelocityThreshold {
			// Medium velocity - move exactly one item
			itemsToMove = 1
			debugLog("Medium velocity (\(absVelocity)), moving 1 item")
		} else {
			// High velocity - calculate based on power curve
			let velocityRatio = absVelocity / mediumVelocityThreshold
			let basePowerFactor = pow(velocityRatio, 1.8)
			let scaledPowerFactor = basePowerFactor * 3.0
			let powerBasedItemsToMove = Int(scaledPowerFactor)
			
			// Ensure we move at least 2 items for high velocity
			itemsToMove = max(2, powerBasedItemsToMove)
			
			// Special case for extremely high velocity
			if absVelocity > 3500 {
				let itemCount = maxItemID - minItemID + 1
				let maxPossibleItems = Int(Double(itemCount) * 0.8)
				itemsToMove = min(maxPossibleItems, max(itemsToMove, Int(itemCount/3)))
				debugLog("Extremely high velocity (\(absVelocity)), allowing long scroll of \(itemsToMove) items")
			}
			
			// Cap to configured limit
			itemsToMove = min(itemsToMove, maxItemsToAdvance)
			
			debugLog("High velocity (\(absVelocity)), velocity ratio: \(velocityRatio), moving \(itemsToMove) items")
		}
		
		// Calculate target item
		let targetItemID: Int
		
		if itemsToMove == 0 {
			// For zero movement, find the truly closest item
			if let exactClosestID = findItemClosestToExactCenter(),
			   let exactOffset = currentOffsets[exactClosestID],
			   abs(exactOffset) < minCorrectionThreshold * 2 {
				// Item is clearly closer to center
				targetItemID = exactClosestID
				debugLog("Using exact closest item: \(exactClosestID)")
			} else {
				// Between items - find best choice
				let sortedItems = currentOffsets.sorted { abs($0.value) < abs($1.value) }
				
				if sortedItems.count >= 2 {
					let firstItem = sortedItems[0]
					let secondItem = sortedItems[1]
					
					if abs(abs(firstItem.value) - abs(secondItem.value)) < minCorrectionThreshold * 1.5 {
						// Almost equally distant - use direction to decide
						if direction != 0 {
							targetItemID = direction > 0 ? max(firstItem.key, secondItem.key) : min(firstItem.key, secondItem.key)
							debugLog("Between items - choosing based on drag direction: \(targetItemID)")
						} else {
							targetItemID = firstItem.key // Mathematically closest
							debugLog("Between items - using mathematically closest: \(targetItemID)")
						}
					} else {
						// One is clearly closer
						targetItemID = firstItem.key
						debugLog("One item is clearly closer: \(targetItemID)")
					}
				} else {
					// Only one item or none - use current
					targetItemID = currentItemID
				}
			}
		} else {
			// For movement, calculate target based on direction and count
			let targetOffset = direction * itemsToMove
			let unboundedTarget = currentItemID + targetOffset
			
			debugLog("Calculation: current(\(currentItemID)) + direction(\(direction)) * items(\(itemsToMove)) = \(unboundedTarget)")
			
			// Ensure within bounds
			targetItemID = max(minItemID, min(maxItemID, unboundedTarget))
			debugLog("Final target (bounded): \(targetItemID)")
		}
		
		// Apply the selection
		if targetItemID != selectedID {
			let oldID = selectedID
			selectedID = targetItemID
			updateExternalBinding(targetItemID)
			
			debugLog("Selection changed from \(oldID) to \(targetItemID)")
		}
		
		// Reset direction tracking
		lastDragDirection = 0
		
		// Calculate animation duration based on distance
		let distance = abs(targetItemID - currentItemID)
		let baseDuration = 0.3
		let maxDuration = 0.8
		let scaledDuration = baseDuration * (1.0 + sqrt(Double(min(distance, 60)) / 5.0))
		let animationDuration = min(scaledDuration, maxDuration)
		
		debugLog("Distance: \(distance), animation duration: \(animationDuration)")
		
		// Use appropriate spring animation based on distance
		if distance > 5 {
			// For longer distances, use tighter spring
			withAnimation(.spring(response: animationDuration, dampingFraction: 0.9, blendDuration: 0.1)) {
				scrollViewReader?.scrollTo(targetItemID, anchor: .center)
			}
		} else {
			// For shorter distances, use bouncier spring
			withAnimation(.spring(response: animationDuration, dampingFraction: 0.8)) {
				scrollViewReader?.scrollTo(targetItemID, anchor: .center)
			}
		}
		
		// Prevent further corrections
		lastCorrectionTime = Date()
		correctionCounter = maxCorrectionAttempts
	}
}
