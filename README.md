# CenteredHorizontalCollection

A SwiftUI package for creating smooth, physics-based horizontal scrolling collections with automatic item centering.

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Available-red.svg)](https://developer.apple.com/xcode/swiftui/)

## Features

- Smooth, automatic item centering with elegant animations
- Enhanced scrolling physics similar to UICollectionView
- Two scrolling behavior modes (standard and enhanced physics)
- Works with any model that conforms to `Identifiable`
- Customizable item appearance with selection state awareness
- Thread-safe configuration using Swift's actor model
- Extensive customization options for layout and animations
- Interactive selection with binding support
- Optimized for performance with efficient view updates


![photo_2025-04-26 23 09 25](https://github.com/user-attachments/assets/069ce56f-3e21-4deb-8ddc-74c780e30ec0)


https://github.com/user-attachments/assets/0da42b89-1099-47da-976f-faa2d16905cc


## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/Maxnxi/CenteredHorizontalCollection.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. Go to File > Add Packages...
2. Enter repository URL: `https://github.com/Maxnxi/CenteredHorizontalCollection.git`
3. Click "Add Package"

## Quick Start

Here's a simple implementation to get you started:

```swift
import SwiftUI
import CenteredHorizontalCollection

struct BasicView: View {
    // Sample items
    let items: [Item] = (1...10).map { Item(id: $0, color: .blue) }
    
    // Track selected item
    @State private var selectedID = 1
    
    var body: some View {
        VStack {
            Text("Selected: \(selectedID)")
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
                .animation(.spring(), value: isSelected)
            }
            .selection($selectedID) // Bind to selection state
            .frame(height: 120)
        }
    }
}
```

## Using with Custom Models

You can use your own model types that conform to `Identifiable`:

```swift
struct Product: Identifiable {
    let id: Int
    let name: String
    let image: String
    let price: Double
}

struct ProductGalleryView: View {
    let products: [Product] = [
        Product(id: 1, name: "Headphones", image: "headphones", price: 99.99),
        Product(id: 2, name: "Smart Watch", image: "watch", price: 249.99),
        // More products...
    ]
    
    @State private var selectedID = 1
    
    var body: some View {
        CenteredHorizontalCollection(items: products) { product, isSelected in
            ProductCardView(product: product, isSelected: isSelected)
        }
        .selection($selectedID)
    }
}
```

## Configuration Options

### Basic Configuration

You can configure the collection's appearance and behavior:

```swift
// At app startup or in your view's .onAppear
Task {
    await HorizontalCollectionConstants.configure(
        itemSize: 80,                      // Size of each item
        itemSpacing: 20,                   // Spacing between items
        debugMode: false,                  // Enable debugging
        scrollBehaviorMode: .targetContentOffset // Enhanced physics
    )
}

// Individual properties can also be set
HorizontalCollectionConstants.selectionAnimationDuration = 0.3
HorizontalCollectionConstants.itemSpacing = 15
```

### Scroll Behavior Modes

The collection supports two scrolling behaviors:

1. **Standard Mode** - Simple selection and centering:
   ```swift
   await HorizontalCollectionConstants.configure(
       scrollBehaviorMode: .standard
   )
   ```

2. **Target Content Offset Mode** - Enhanced physics with better momentum:
   ```swift
   await HorizontalCollectionConstants.configure(
       scrollBehaviorMode: .targetContentOffset
   )
   ```

The target content offset mode provides a more natural scrolling experience with velocity-based targeting, especially for fast scrolling gestures.

### Advanced Configuration

Fine-tune the collection's behavior for specialized use cases:

```swift
// Adjust animation timing
HorizontalCollectionConstants.selectionAnimationDuration = 0.25
HorizontalCollectionConstants.selectionAnimationDuringDrag = 0.1

// Configure scrolling physics
HorizontalCollectionConstants.lowVelocityThreshold = 50.0
HorizontalCollectionConstants.mediumVelocityThreshold = 200.0
HorizontalCollectionConstants.scrollDebounceTime = 0.15

// Adjust centering behavior
HorizontalCollectionConstants.minCorrectionThreshold = 3.0
HorizontalCollectionConstants.maxCorrectionThreshold = 45.0
```

## Customizing Animations

Custom animations provide a polished user experience:

```swift
CenteredHorizontalCollection(items: items) { item, isSelected in
    MyItemView(item: item)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .opacity(isSelected ? 1.0 : 0.7)
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

## Performance Tips

- For large collections, use smaller `itemSize` values
- Disable debug mode in production for better performance
- Use appropriate animation complexity based on your target devices
- Consider limiting very complex animations to selected items only
- For very large data sets, consider pagination strategies

## Full Demo

A complete interactive demonstration is included in the package:

```swift
import SwiftUI
import CenteredHorizontalCollection

struct ContentView: View {
    var body: some View {
        DemoView()
    }
}
```

Check out the `DemoView.swift` in the Examples directory for a demonstration of all features with interactive configuration controls.

## Thread Safety

The package uses Swift's actor model to ensure thread safety for all configuration operations. This allows safe concurrent access in multi-threaded environments.

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+
- Xcode 15.0+

## License

CenteredHorizontalCollection is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Author

Created by Maksim Ponomarev
