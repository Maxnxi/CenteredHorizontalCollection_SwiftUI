// The Swift Programming Language
// https://docs.swift.org/swift-book

//
//  CenteredHorizontalCollection.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/25/25.
//

import SwiftUI
import Combine

/// A horizontally scrolling collection that centers items and provides selection handling
public struct CenteredHorizontalCollection<T: Identifiable>: View {
	// ViewModel to handle scroll logic
	@StateObject private var viewModel = CenteredScrollViewModel()
	
	// Collection items
	private let items: [T]
	
	// Configuration options
	private let itemSpacing: CGFloat
	private let itemBuilder: (T, Bool) -> AnyView
	
	// For accessing actor-isolated properties
	@State private var cornerSpacerWidth: CGFloat = 0
		
	private var selectionBinding: Binding<Int>?
	
	// Function to convert item.id to Int consistently
	private func getItemNumericID(_ item: T) -> Int {
		// If the id is already an Int, use it directly
		if let intID = item.id as? Int {
			return intID
		}
		
		// Otherwise, use a consistent hash (not hashValue which can change)
		// We'll use String representation as intermediary for non-int IDs
		return "\(item.id)".hashValue
	}
	
	/// Creates a new CenteredHorizontalCollection with custom item views
	/// - Parameters:
	///   - items: Array of identifiable items to display in the collection
	///   - itemSpacing: Spacing between items (defaults to standard spacing)
	///   - itemBuilder: A closure that creates a view for each item, with parameters for the item and whether it's selected
	public init(
		items: [T],
		itemSpacing: CGFloat = 16,
		selection: Binding<Int>? = nil,
		@ViewBuilder itemBuilder: @escaping (T, Bool) -> some View
	) {
		self.items = items
		self.itemSpacing = itemSpacing
		self.selectionBinding = selection
		self.itemBuilder = { item, isSelected in
			AnyView(itemBuilder(item, isSelected))
		}
	}
	
	public var body: some View {
		VStack {
			// The main horizontal collection
			ScrollViewReader { proxy in
				ScrollView(
					.horizontal,
					showsIndicators: false
				) {
					HStack(spacing: itemSpacing) {
						// Add spacer at the beginning to allow first item to center
						Spacer()
							.frame(width: calculateSpacerWidth())
						
						ForEach(items) { item in
							let itemID = getItemNumericID(item)
							
							itemBuilder(item, viewModel.selectedID == itemID)
								.id(itemID)
								.overlay(
									GeometryReader { geo in
										Color.clear
											.preference(
												key: OffsetPreferenceKey.self,
												value: [itemID: viewModel.computeOffset(geo: geo)]
											)
									}
								)
								.onTapGesture {
									// Handle item tap
									viewModel.selectItem(itemID)
									
									// Update external binding if available
									if let binding = selectionBinding {
										binding.wrappedValue = itemID
									}
								}
						}
						
						// Add spacer at the end to allow last item to center
						Spacer()
							.frame(width: calculateSpacerWidth())
					}
				}
				.onPreferenceChange(OffsetPreferenceKey.self) { offsets in
					Task { @MainActor in
						viewModel.updateOffsets(offsets)
						
						// Update external binding if available when selection changes due to scrolling
						if let binding = selectionBinding, binding.wrappedValue != viewModel.selectedID {
							binding.wrappedValue = viewModel.selectedID
						}
					}
				}
				.simultaneousGesture(
					DragGesture(minimumDistance: 5)
						.onChanged { _ in
							viewModel.startDragging()
						}
						.onEnded { _ in
							viewModel.endDragging()
						}
				)
				.task {
					// Initialize selection from binding if available
					if let binding = selectionBinding {
						viewModel.selectedID = binding.wrappedValue
					}
					
					viewModel.setScrollViewReader(proxy)

					// Load actor constants at initialization
					let itemSize = HorizontalCollectionConstants.itemSize
					cornerSpacerWidth = (HorizontalCollectionConstants.screenWidth - itemSize) / 2
					
					// Bind to external selection properly
					if let binding = selectionBinding {
						viewModel.bindToExternalSelection(binding)
					}
				}
				// Watch for external selection changes and scroll to the item
				.onChange(of: selectionBinding?.wrappedValue) { newID in
					if let newID, newID != viewModel.selectedID {
						// Programmatically select and scroll to this item
						viewModel.selectItem(newID)
					}
				}
			}
		}
	}
	
	/// Calculate spacer width safely without awaiting actor
	private func calculateSpacerWidth() -> CGFloat {
		// Use cached value from task if available
		if cornerSpacerWidth > 0 {
			return cornerSpacerWidth
		}
		
		// Fallback calculation if actor value not yet loaded
		return (HorizontalCollectionConstants.screenWidth / 2) - 28
	}
	
	/// Retrieves the currently selected item ID
	public var selectedID: Int {
		viewModel.selectedID
	}
	
	/// Binds to an external selection ID
	public func selection(_ id: Binding<Int>) -> Self {
		var copy = self
		copy.selectionBinding = id
		return copy
	}
	
	/// Programmatically selects an item by ID
	public func selectItem(_ id: Int) {
		viewModel.selectItem(id)
	}
}
