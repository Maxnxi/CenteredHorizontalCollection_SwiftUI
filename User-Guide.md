# CenteredHorizontalCollection Usage Guide

This document provides comprehensive examples and usage patterns for the CenteredHorizontalCollection package.

## Basic Implementation

Here's a simple implementation of the collection with custom items:

```swift
import SwiftUI
import CenteredHorizontalCollection

struct BasicImplementationView: View {
    // Create some sample data
    let items: [Item] = (1...10).map { Item(id: $0, color: .blue) }
    
    // Keep track of the selected item
    @State private var selectedID = 1
    
    var body: some View {
        VStack {
            Text("Selected Item: \(selectedID)")
                .padding()
            
            // Implement the collection with custom item views
            CenteredHorizontalCollection(items: items) { item, isSelected in
                // Custom item view
                ZStack {
                    Circle()
                        .fill(item.color)
                        .frame(width: 70, height: 70)
                    
                    Text("\(item.id)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .scaleEffect(isSelected ? 1.1 : 0.9)
                .shadow(radius: isSelected ? 8 : 2)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
            .selection($selectedID) // Bind to our selection state
            .frame(height: 120)
        }
    }
}
```

## Using with Custom Models

You can use your own custom model types with the collection, as long as they conform to `Identifiable`:

```swift
import SwiftUI
import CenteredHorizontalCollection

// Define your custom model
struct Product: Identifiable {
    let id: Int
    let name: String
    let image: String // Image name
    let price: Double
}

struct ProductGalleryView: View {
    // Sample product data
    let products: [Product] = [
        Product(id: 1, name: "Headphones", image: "headphones", price: 99.99),
        Product(id: 2, name: "Smart Watch", image: "watch", price: 249.99),
        Product(id: 3, name: "Bluetooth Speaker", image: "speaker", price: 59.99),
        Product(id: 4, name: "Laptop", image: "laptop", price: 1299.99),
        Product(id: 5, name: "Smartphone", image: "phone", price: 899.99)
    ]
    
    @State private var selectedID = 1
    
    var body: some View {
        VStack {
            Text("Featured Products")
                .font(.largeTitle)
                .padding()
            
            // Show the selected product details
            if let selectedProduct = products.first(where: { $0.id == selectedID }) {
                Text(selectedProduct.name)
                    .font(.headline)
                
                Text("$\(String(format: "%.2f", selectedProduct.price))")
                    .foregroundColor(.green)
            }
            
            // Use the collection with our custom products
            CenteredHorizontalCollection(items: products) { product, isSelected in
                VStack {
                    Image(systemName: product.image)
                        .font(.system(size: 32))
                        .foregroundColor(isSelected ? .blue : .gray)
                    
                    Text(product.name)
                        .font(.caption)
                        .foregroundColor(isSelected ? .primary : .secondary)
                }
                .frame(width: 100, height: 100)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: isSelected ? 5 : 1)
                .scaleEffect(isSelected ? 1.1 : 0.95)
                .animation(.spring(), value: isSelected)
            }
            .selection($selectedID)
            .frame(height: 150)
            
            // Add buy button for selected product
            Button("Add to Cart") {
                // Handle purchase
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding()
        }
        .padding()
    }
}
```

## Working with Non-Integer IDs

CenteredHorizontalCollection works with any `Identifiable` model, even if the ID is not an integer:

```swift
// Model with UUID
struct Post: Identifiable {
    let id: UUID
    let title: String
    let imageURL: URL
    
    init(id: UUID = UUID(), title: String, imageURL: URL) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
    }
}

// Use it with the collection
let posts = [
    Post(title: "First Post", imageURL: URL(string: "https://example.com/1")!),
    Post(title: "Second Post", imageURL: URL(string: "https://example.com/2")!),
    Post(title: "Third Post", imageURL: URL(string: "https://example.com/3")!)
]

CenteredHorizontalCollection(items: posts) { post, isSelected in
    PostCard(post: post, isSelected: isSelected)
}
```

The collection internally converts any ID type to a consistent integer for tracking.

## Configuration Options

You can configure many aspects of the collection using the actor-based configuration system:

```swift
Task {
    // Configure at app startup or in your view's .onAppear
    await HorizontalCollectionConstants.configure(
        itemSize: 80,                      // Size of each item
        itemSpacing: 20,                   // Spacing between items
        debugMode: false,                  // Enable debugging
        scrollBehaviorMode: .targetContentOffset // Enhanced physics
    )

    // Individual properties can also be set
    HorizontalCollectionConstants.selectionAnimationDuration = 0.3
    HorizontalCollectionConstants.itemSpacing = 15
    HorizontalCollectionConstants.lowVelocityThreshold = 50.0
}
```

## Scroll Behavior Modes

The collection supports two scrolling behavior modes:

1. **Standard Mode** - Simple selection and centering with basic physics:
   ```swift
   await HorizontalCollectionConstants.configure(
       scrollBehaviorMode: .standard
   )
   ```

2. **Target Content Offset Mode** - Enhanced scrolling with better physics similar to UICollectionView:
   ```swift
   await HorizontalCollectionConstants.configure(
       scrollBehaviorMode: .targetContentOffset
   )
   ```

The target content offset mode provides a more natural scrolling experience with velocity-based targeting, especially for fast scrolling actions.

## Performance Tips

- For large collections, consider using a smaller `itemSize` to ensure more items are visible
- If scrolling performance degrades, try disabling debug mode
- Avoid overly complex item views with excessive shadows, animations, or effects
- For very large collections (50+ items), consider implementing pagination or lazy loading
- Use minimal animations for selection state changes on low-end devices
- Cache asset images rather than loading them for each item render

## Customizing Animations

You can adjust animation timing and feel:

```swift
// Configure timing constants
Task {
    await HorizontalCollectionConstants.configure()
    HorizontalCollectionConstants.selectionAnimationDuration = 0.25
    HorizontalCollectionConstants.selectionAnimationDuringDrag = 0.1
}

// Custom animation in your item view builder
CenteredHorizontalCollection(items: items) { item, isSelected in
    MyCustomView(item: item)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(
            .spring(
                response: 0.3,
                dampingFraction: 0.7,
                blendDuration: 0.1
            ),
            value: isSelected
        )
}
```

## Handling Selection Changes

You can respond to selection changes in several ways:

```swift
struct SelectionDemoView: View {
    @State private var selectedID = 1
    
    var body: some View {
        VStack {
            // The collection with binding
            CenteredHorizontalCollection(items: items, selection: $selectedID) { item, isSelected in
                ItemView(item: item, isSelected: isSelected)
            }
            
            // Option 1: Observe using onChange
            .onChange(of: selectedID) { newValue in
                print("Selection changed to: \(newValue)")
                // Perform actions based on new selection
            }
            
            // Option 2: Use a computed property
            Text("Selected: \(selectedItemName)")
            
            // Option 3: Use a button that acts on current selection
            Button("Add \(selectedItemName) to Cart") {
                addToCart(id: selectedID)
            }
        }
    }
    
    // Computed property based on selection
    var selectedItemName: String {
        items.first(where: { $0.id == selectedID })?.name ?? "Unknown"
    }
    
    func addToCart(id: Int) {
        // Implementation
    }
}
```

## Programmatic Selection and Navigation

You can programmatically control the selection:

```swift
struct NavigationDemoView: View {
    @State private var selectedID = 1
    let items: [Item] = (1...10).map { Item(id: $0, color: .blue) }
    
    var body: some View {
        VStack {
            // Collection with selection binding
            CenteredHorizontalCollection(items: items, selection: $selectedID) { item, isSelected in
                ItemView(item: item, isSelected: isSelected)
            }
            
            // Navigation controls
            HStack {
                Button("Previous") {
                    if selectedID > 1 {
                        selectedID -= 1
                    }
                }
                .disabled(selectedID == 1)
                
                Button("Next") {
                    if selectedID < items.count {
                        selectedID += 1
                    }
                }
                .disabled(selectedID == items.count)
                
                Button("Random") {
                    selectedID = Int.random(in: 1...items.count)
                }
            }
            
            // Quick access
            HStack {
                ForEach([1, 3, 5, 7, 9], id: \.self) { index in
                    Button("\(index)") {
                        selectedID = index
                    }
                    .padding(5)
                    .background(selectedID == index ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                }
            }
        }
    }
}
```

## Integration with Other SwiftUI Components

The collection works well with other SwiftUI components like TabView:

```swift
TabView {
    // First tab
    VStack {
        Text("Featured Products")
            .font(.headline)
        
        CenteredHorizontalCollection(items: products) { product, isSelected in
            ProductCardView(product: product, isSelected: isSelected)
        }
    }
    .tabItem {
        Label("Products", systemImage: "square.grid.2x2")
    }
    
    // Second tab
    VStack {
        Text("Categories")
            .font(.headline)
            
        CenteredHorizontalCollection(items: categories) { category, isSelected in
            CategoryView(category: category, isSelected: isSelected)
        }
    }
    .tabItem {
        Label("Categories", systemImage: "folder")
    }
}
```

## Advanced Styling Examples

Here are some styling examples to inspire your custom item views:

### Minimalist Cards

```swift
CenteredHorizontalCollection(items: items) { item, isSelected in
    VStack {
        Circle()
            .fill(item.color.opacity(0.8))
            .frame(width: 50, height: 50)
        
        Text(item.title)
            .font(.caption)
            .foregroundColor(isSelected ? .primary : .secondary)
    }
    .frame(width: 80, height: 100)
    .background(Color.white)
    .cornerRadius(8)
    .shadow(color: Color.black.opacity(0.05), radius: isSelected ? 5 : 2, x: 0, y: isSelected ? 3 : 1)
    .scaleEffect(isSelected ? 1.05 : 0.98)
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
}
```

### 3D Rotation Effect

```swift
CenteredHorizontalCollection(items: items) { item, isSelected in
    ZStack {
        RoundedRectangle(cornerRadius: 12)
            .fill(item.color)
            .frame(width: 100, height: 120)
        
        Text(item.title)
            .font(.system(.headline, design: .rounded))
            .foregroundColor(.white)
    }
    .rotation3DEffect(
        isSelected ? .degrees(0) : .degrees(-15),
        axis: (x: 0, y: 1, z: 0),
        anchor: .leading
    )
    .shadow(color: item.color.opacity(0.5), radius: isSelected ? 8 : 2)
    .animation(.spring(response: 0.4, dampingFraction: 0.65), value: isSelected)
}
```

### Interactive Cards

```swift
CenteredHorizontalCollection(items: products) { product, isSelected in
    VStack(spacing: 8) {
        Image(systemName: product.icon)
            .font(.system(size: 28))
            .foregroundColor(isSelected ? product.color : .gray)
        
        Text(product.name)
            .font(.caption)
            .fontWeight(isSelected ? .bold : .regular)
        
        if isSelected {
            Text("$\(String(format: "%.2f", product.price))")
                .font(.caption2)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.green.opacity(0.1))
                .cornerRadius(4)
                .transition(.scale.combined(with: .opacity))
        }
    }
    .frame(width: 90, height: 110)
    .padding(.vertical, 10)
    .background(Color.white)
    .cornerRadius(12)
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(isSelected ? product.color : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
    )
    .shadow(color: isSelected ? product.color.opacity(0.3) : Color.clear, radius: 8)
    .scaleEffect(isSelected ? 1.08 : 1.0)
    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
}
```

## Full Interactive Demo

Check out the `DemoView.swift` in the Examples directory for a complete interactive demonstration of all the collection's features. The demo includes:

- Multiple display themes
- Configuration options for item size and spacing
- Toggle for debug mode
- Selector for scrolling behavior mode
- Programmatic selection controls
- Performance testing with many items

## Troubleshooting

### Common Issues and Solutions

1. **Items not centering properly**
   - Ensure you're using the correct `.selection()` binding
   - Check if the item spacing is set appropriately for your item size
   - Verify that the frame height is sufficient for your item views

2. **Scrolling feels jerky or unnatural**
   - Switch to `.targetContentOffset` scrolling behavior mode
   - Reduce the complexity of your item views
   - Ensure you're not applying too many animations simultaneously

3. **Selection not updating**
   - Verify your binding is correctly implemented
   - Check for any code that might be overriding the selection
   - Ensure your `Identifiable` model has unique IDs

4. **Layout issues on different screen sizes**
   - Use relative sizing rather than fixed sizes where possible
   - Consider using GeometryReader to adapt to available space
   - Test on multiple device sizes during development

### Tips for Better Performance

- Keep item views as simple as possible
- Use appropriate animation complexity based on target devices
- Implement pagination for very large collections
- Consider lazy loading for image-heavy item views
- Use the standard scrolling mode for lower-end devices if needed
