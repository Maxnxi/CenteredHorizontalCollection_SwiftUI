# CenteredHorizontalCollection

A SwiftUI package for creating smooth, physics-based horizontal scrolling collections with automatic item centering.

## Overview

CenteredHorizontalCollection provides a highly customizable horizontal collection view that:

- Centers items automatically with sophisticated animations
- Offers enhanced scrolling physics with natural momentum
- Supports fully customizable item views with selection state
- Works with any model that conforms to Identifiable
- Provides extensive configuration options through an actor-based API
- Features both standard and enhanced scrolling physics modes

Perfect for creating carousels, pickers, galleries, and any horizontal scrolling interface that requires professional-grade scrolling behavior with minimal code.

## Key Features

- **Smooth Physics-Based Scrolling**: Provides a natural, fluid scrolling experience similar to native UIKit controls
- **Automatic Item Centering**: Items snap to center with customizable animations
- **Selection Management**: Built-in selection handling with optional binding support
- **Thread-Safe Configuration**: Actor-based configuration system for concurrency safety
- **Velocity-Based Targeting**: Enhanced scrolling mode that intelligently targets items based on velocity and direction
- **Fully Customizable Items**: Complete freedom to design your item views with selection state awareness
- **Generic Implementation**: Works with any Identifiable model without modification
- **Comprehensive Documentation**: Detailed usage guides and architecture documentation

## Example Usage

Basic implementation with custom items:

```swift
CenteredHorizontalCollection(items: myItems) { item, isSelected in
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
.selection($selectedID) // Optional binding
.frame(height: 120)
```

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the package to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/Maxnxi/CenteredHorizontalCollection.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File > Add Packages...
2. Enter package URL: `https://github.com/Maxnxi/CenteredHorizontalCollection.git`
3. Select "Up to Next Major Version"

## Documentation

For complete implementation details and advanced usage, see:

- [User Guide](Documentation/User-Guide.md)
- [Architecture](Documentation/Architecture.md)
- [Example App](Examples/DemoView.swift)

## License

CenteredHorizontalCollection is available under the MIT license.
See the [LICENSE](LICENSE) file for details.
