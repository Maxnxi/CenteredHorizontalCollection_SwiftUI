//
//  DemoView.swift
//  CenteredHorizontalCollectionSwiftUIExample
//
//  Created by Maksim Ponomarev on 4/25/25.
//

import SwiftUI
import CenteredHorizontalCollection

/// Example demo view showing how to use the CenteredHorizontalCollection
struct DemoView: View {
	// State for tracking selected item
	@State private var selectedID = 1
	
	// State for storing loaded configuration values
	@State private var debugMode = false
	@State private var scrollBehaviorMode = 0
	
	// Reference to the collection to allow programmatic control
	@State private var collectionRef: CenteredHorizontalCollection<Item>? = nil
	
	// Sample data for the collection
	let items: [Item] = (1...20).map { Item(id: $0, color: Color(
		red: Double.random(in: 0...1),
		green: Double.random(in: 0...1),
		blue: Double.random(in: 0...1)))
	}
	
	var body: some View {
		VStack {
			Text("Centered Collection Demo")
				.font(.headline)
				.padding()
			
			// Display selected item for demonstration purposes
			Text("Selected Item: \(selectedID)")
				.padding(.bottom)
			
			// The main horizontal collection with custom item view
			CenteredHorizontalCollection(items: items, selection: $selectedID) { item, isSelected in
				// Custom item view builder
				RoundedRectangle(cornerRadius: 8)
					.fill(item.color)
					.frame(width: 60, height: 60)
					.overlay(
						Text("\(item.id)")
							.foregroundColor(.white)
					)
					.shadow(radius: isSelected ? 6 : 2)
					.scaleEffect(isSelected ? 1.1 : 0.9)
			}
			
			// Navigation buttons with visual selection state
			HStack(spacing: 20) {
				Button(action: {
					if selectedID > 1 {
						selectedID -= 1
					}
				}) {
					Label("Previous", systemImage: "chevron.left")
						.padding(.horizontal, 12)
						.padding(.vertical, 8)
						.background(Color.blue.opacity(0.1))
						.cornerRadius(8)
				}
				.disabled(selectedID <= 1)
				.opacity(selectedID <= 1 ? 0.5 : 1.0)
				
				Button(action: {
					if selectedID < items.count {
						selectedID += 1
					}
				}) {
					Label("Next", systemImage: "chevron.right")
						.padding(.horizontal, 12)
						.padding(.vertical, 8)
						.background(Color.blue.opacity(0.1))
						.cornerRadius(8)
				}
				.disabled(selectedID >= items.count)
				.opacity(selectedID >= items.count ? 0.5 : 1.0)
			}
			.padding()
			
			// Add more visual feedback for selection state
			HStack(spacing: 4) {
				ForEach(1...min(10, items.count), id: \.self) { index in
					Circle()
						.fill(index == selectedID ? Color.blue : Color.gray.opacity(0.3))
						.frame(width: 8, height: 8)
				}
			}
			.padding(.bottom)
			
			// Configuration section
			VStack(alignment: .leading, spacing: 10) {
				Text("Configuration Options")
					.font(.subheadline)
					.fontWeight(.bold)
				
				Toggle("Debug Mode", isOn: $debugMode)
					.onChange(of: debugMode) { value in
						Task {
							await HorizontalCollectionConstants.configure(debugMode: value)
						}
					}
				
				HStack {
					Text("Scroll Behavior:")
					Picker("Scroll Behavior", selection: $scrollBehaviorMode) {
						Text("Standard").tag(0)
						Text("Enhanced").tag(1)
					}
					.pickerStyle(SegmentedPickerStyle())
					.onChange(of: scrollBehaviorMode) { value in
						Task {
							await HorizontalCollectionConstants.configure(
								scrollBehaviorMode: value == 0 ? .standard : .targetContentOffset
							)
						}
					}
				}
				
				// Add a manual jump to specific item
				HStack {
					Text("Jump to item:")
					Spacer(minLength: 20)
					HStack(spacing: 8) {
						ForEach([1, 5, 10, 15, 20], id: \.self) { index in
							if index <= items.count {
								Button(action: {
									// Just update the binding
									selectedID = index
								}, label: {
									Text("\(index)")
										.frame(minWidth: 20)
										.lineLimit(1)
								})
								.padding(.horizontal, 8)
								.padding(.vertical, 4)
								.background(selectedID == index ? Color.blue : Color.gray.opacity(0.2))
								.foregroundColor(selectedID == index ? Color.white : Color.primary)
								.cornerRadius(4)
							}
						}
					}
				}
				.padding(.top, 4)
			}
			.padding()
			.background(Color.gray.opacity(0.1))
			.cornerRadius(8)
			.padding(.horizontal)
			
			// Add selection status log
			VStack(alignment: .leading) {
				Text("Selection Status")
					.font(.caption)
					.fontWeight(.bold)
				
				Text("Current selection: Item #\(selectedID)")
					.font(.caption)
					.foregroundColor(.secondary)
				
				Text("Try selecting items by tapping or using the navigation buttons.")
					.font(.caption)
					.foregroundColor(.secondary)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal)
			.padding(.top, 8)
		}
		.task {
			// Load the current configurations
			do {
				debugMode = HorizontalCollectionConstants.debugMode
				scrollBehaviorMode = HorizontalCollectionConstants.scrollBehaviorMode == .standard ? 0 : 1
			} catch {
				print("Error loading configuration: \(error)")
			}
			
			// Configure the collection
			await HorizontalCollectionConstants.configure(
				itemSize: 60,
				itemSpacing: 16,
				debugMode: false,
				scrollBehaviorMode: .targetContentOffset
			)
		}
		.onChange(of: selectedID) { newValue in
			// This allows us to verify the binding is working
			print("DemoView: Selection changed to \(newValue)")
		}
	}
}

#Preview {
    DemoView()
}
