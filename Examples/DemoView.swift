//
//  DemoView.swift
//  CenteredHorizontalCollection
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
	@State private var itemSize: Double = 60
	@State private var itemSpacing: Double = 16
	@State private var currentTheme = 0
	
	// Sample data for the collection
	let items: [Item] = (1...20).map { Item(id: $0, color: Color(
		red: Double.random(in: 0...1),
		green: Double.random(in: 0...1),
		blue: Double.random(in: 0...1)))
	}
	
	// Different themes for items
	let themes = ["Standard", "Minimalist", "Vibrant", "3D Effect"]
	
	var body: some View {
		VStack {
			// Header
			Text("Centered Collection Demo")
				.font(.headline)
				.fontWeight(.bold)
				.padding()
			
			// Display selected item for demonstration purposes
			Text("Selected Item: \(selectedID)")
				.font(.subheadline)
				.padding(.bottom)
			
			// The main horizontal collection with custom item view
			CenteredHorizontalCollection(items: items) { item, isSelected in
				// Custom item view builder based on theme
				itemView(for: item, isSelected: isSelected)
			}
			.selection($selectedID)
			
			// Navigation buttons
			HStack(spacing: 20) {
				Button(action: {
					if selectedID > 1 {
						selectedID -= 1
					}
				}) {
					Label("Previous", systemImage: "chevron.left")
						.padding(.horizontal, 10)
						.padding(.vertical, 5)
						.background(Color.blue.opacity(0.1))
						.cornerRadius(8)
				}
				.disabled(selectedID <= 1)
				
				Button(action: {
					if selectedID < items.count {
						selectedID += 1
					}
				}) {
					Label("Next", systemImage: "chevron.right")
						.padding(.horizontal, 10)
						.padding(.vertical, 5)
						.background(Color.blue.opacity(0.1))
						.cornerRadius(8)
				}
				.disabled(selectedID >= items.count)
			}
			.padding()
			
			// Theme picker
			Picker("Display Style", selection: $currentTheme) {
				ForEach(0..<themes.count, id: \.self) { index in
					Text(themes[index]).tag(index)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			.padding(.horizontal)
			.padding(.bottom, 10)
			
			// Configuration section
			VStack(alignment: .leading, spacing: 10) {
				Text("Configuration Options")
					.font(.subheadline)
					.fontWeight(.bold)
				
				// Item size slider
				HStack {
					Text("Item Size:")
					Slider(value: $itemSize, in: 40...120, step: 5)
						.onChange(of: itemSize) { value in
							Task {
								await HorizontalCollectionConstants.configure(
									itemSize: value
								)
							}
						}
					Text("\(Int(itemSize))")
						.frame(width: 30)
				}
				
				// Item spacing slider
				HStack {
					Text("Spacing:")
					Slider(value: $itemSpacing, in: 4...40, step: 2)
						.onChange(of: itemSpacing) { value in
							Task {
								await HorizontalCollectionConstants.configure(
									itemSpacing: value
								)
							}
						}
					Text("\(Int(itemSpacing))")
						.frame(width: 30)
				}
				
				Divider()
				
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
				
				// Action Buttons for demo
				HStack {
					Button("Reset") {
						resetToDefaults()
					}
					.padding(.horizontal, 12)
					.padding(.vertical, 6)
					.background(Color.red.opacity(0.1))
					.cornerRadius(8)
					
					Spacer()
					
					Button("Random Selection") {
						selectedID = Int.random(in: 1...items.count)
					}
					.padding(.horizontal, 12)
					.padding(.vertical, 6)
					.background(Color.green.opacity(0.1))
					.cornerRadius(8)
				}
				.padding(.top, 5)
			}
			.padding()
			.background(Color.gray.opacity(0.1))
			.cornerRadius(12)
			.padding(.horizontal)
			
			// Information section
			VStack(alignment: .leading, spacing: 5) {
				Text("Tip: Try scrolling quickly with Enhanced scroll behavior mode.")
					.font(.caption)
					.foregroundColor(.secondary)
				
				Text("Use the configuration options to experiment with different settings.")
					.font(.caption)
					.foregroundColor(.secondary)
			}
			.padding(.horizontal)
			.padding(.top, 5)
		}
		.task {
			// Load the current configurations
			do {
				debugMode = try await HorizontalCollectionConstants.debugMode
				scrollBehaviorMode = try await HorizontalCollectionConstants.scrollBehaviorMode == .standard ? 0 : 1
				itemSize = try await HorizontalCollectionConstants.itemSize
				itemSpacing = try await HorizontalCollectionConstants.itemSpacing
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
	}
	
	// Helper to create themed item views
	private func itemView(for item: Item, isSelected: Bool) -> some View {
		Group {
			switch currentTheme {
			case 0: // Standard
				RoundedRectangle(cornerRadius: 8)
					.fill(item.color)
					.frame(width: itemSize, height: itemSize)
					.overlay(
						Text("\(item.id)")
							.foregroundColor(.white)
							.fontWeight(.bold)
					)
					.shadow(radius: isSelected ? 6 : 2)
					.scaleEffect(isSelected ? 1.1 : 0.9)
				
			case 1: // Minimalist
				Circle()
					.stroke(item.color, lineWidth: isSelected ? 3 : 1)
					.background(Circle().fill(Color.white))
					.frame(width: itemSize, height: itemSize)
					.overlay(
						Text("\(item.id)")
							.foregroundColor(item.color)
							.fontWeight(isSelected ? .bold : .regular)
					)
					.scaleEffect(isSelected ? 1.05 : 1.0)
				
			case 2: // Vibrant
				ZStack {
					Circle()
						.fill(item.color)
					Circle()
						.fill(item.color.opacity(0.7))
						.scaleEffect(0.8)
					Circle()
						.fill(Color.white.opacity(0.9))
						.scaleEffect(0.5)
					Text("\(item.id)")
						.font(.system(size: itemSize * 0.3))
						.fontWeight(.black)
						.foregroundColor(item.color)
				}
				.frame(width: itemSize, height: itemSize)
				.shadow(color: item.color.opacity(0.5), radius: isSelected ? 10 : 2, x: 0, y: isSelected ? 5 : 1)
				.scaleEffect(isSelected ? 1.15 : 0.95)
				.rotationEffect(isSelected ? .degrees(0) : .degrees(-5))
				
			case 3: // 3D Effect
				ZStack {
					RoundedRectangle(cornerRadius: 12)
						.fill(item.color.opacity(0.8))
						.frame(width: itemSize, height: itemSize)
						.shadow(color: Color.black.opacity(0.2), radius: 2, x: 4, y: 4)
					
					RoundedRectangle(cornerRadius: 12)
						.stroke(Color.white.opacity(0.6), lineWidth: 2)
						.frame(width: itemSize - 2, height: itemSize - 2)
					
					Text("\(item.id)")
						.font(.system(size: itemSize * 0.35, weight: .bold, design: .rounded))
						.foregroundColor(.white)
				}
				.rotation3DEffect(
					isSelected ? .degrees(15) : .degrees(0),
					axis: (x: 0, y: 1, z: 0)
				)
				.scaleEffect(isSelected ? 1.1 : 0.9)
				
			default:
				RoundedRectangle(cornerRadius: 8)
					.fill(item.color)
					.frame(width: itemSize, height: itemSize)
					.overlay(
						Text("\(item.id)")
							.foregroundColor(.white)
					)
					.shadow(radius: isSelected ? 6 : 2)
					.scaleEffect(isSelected ? 1.1 : 0.9)
			}
		}
		.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
		.animation(.spring(response: 0.4), value: currentTheme)
	}
	
	// Reset configuration to defaults
	private func resetToDefaults() {
		itemSize = 60
		itemSpacing = 16
		debugMode = false
		scrollBehaviorMode = 1 // Enhanced
		currentTheme = 0
		selectedID = 1
		
		Task {
			await HorizontalCollectionConstants.configure(
				itemSize: 60,
				itemSpacing: 16,
				debugMode: false,
				scrollBehaviorMode: .targetContentOffset
			)
		}
	}
}

#Preview {
	DemoView()
}
