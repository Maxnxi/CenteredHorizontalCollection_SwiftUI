# CenteredHorizontalCollection Architecture

This document outlines the architectural design and implementation details of the CenteredHorizontalCollection package.

## Package Structure

```
CenteredHorizontalCollection/
├── Sources/
│   └── CenteredHorizontalCollection/
│       ├── CenteredHorizontalCollection.swift  // Main component
│       ├── Models/
│       │   └── Item.swift                      // Sample model
│       ├── Utils/
│       │   ├── DebugUtility.swift              // Debugging helper
│       │   ├── HorizontalCollectionConstants.swift  // Configuration actor
│       │   ├── OffsetPreferenceKey.swift       // Preference key
│       │   └── ScrollBehaviorMode.swift        // Enum for scroll modes
│       ├── ViewModel/
│       │   └── CenteredScrollViewModel.swift   // Logic controller
│       └── Views/
│           └── ItemView.swift                  // Sample item view
├── Tests/
│   └── CenteredHorizontalCollectionTests/
│       └── CenteredHorizontalCollectionTests.swift
├── Examples/
│   └── DemoView.swift                         // Demo implementation
└── Documentation/
    ├── User-Guide.md                          // Usage examples
    └── Architecture.md                         // This file
```

## Core Components

### 1. CenteredHorizontalCollection

The main SwiftUI view that implements the horizontal scrolling collection with centering capabilities. It uses a generic approach that works with any `Identifiable` model type:

```swift
public struct CenteredHorizontalCollection<T: Identifiable>: View {
    // ViewModel and configuration
    @StateObject private var viewModel = CenteredScrollViewModel()
    
    // Collection items
    private let items: [T]
    
    public init(
        items: [T],
        itemSpacing: CGFloat = 16,
        selection: Binding<Int>? = nil,
        @ViewBuilder itemBuilder: @escaping (T, Bool) -> some View
    ) {
        // ...
    }
    
    public var body: some View {
        // ScrollView implementation with GeometryReader and preference keys
        // ...
    }
}
```

The collection leverages SwiftUI's `ScrollViewReader` and `GeometryReader` to track item positions and handle scrolling. It provides a flexible API with selection binding support and custom view builders for item appearance.

### 2. CenteredScrollViewModel

This `@MainActor` ViewModel manages all the scrolling logic, selection tracking, and centering behavior:

```swift
@MainActor
class CenteredScrollViewModel: ObservableObject {
    @Published var selectedID: Int = 1
    @Published var isDragging: Bool = false
    @Published var isManuallySelected: Bool = false
    
    // Methods for handling scrolling physics and selection
    // ...
}
```

Key responsibilities:

- Tracking drag gestures and scroll momentum
- Calculating item positions and offsets
- Determining which item to center based on velocity and position
- Managing selection state with optional external binding
- Implementing different scrolling behaviors (.standard vs .targetContentOffset)
- Handling scroll physics calculations for natural feel
- Managing correction and centering logic

### 3. Preference Keys and Geometry

The `OffsetPreferenceKey` is used to track the position of each item relative to the center of the screen:

```swift
struct OffsetPreferenceKey: PreferenceKey {
    // Using a computed property to avoid shared mutable state
    static var defaultValue: [Int: CGFloat] { [:] }
    
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { (_, new) in new }
    }
}
```

This preference key allows the view model to:
- Determine which item is closest to center
- Calculate scroll velocity and direction
- Make intelligent decisions about centering and selection
- Track item positions for velocity-based targeting

### 4. HorizontalCollectionConstants

This is an actor-based configuration system that provides thread-safe access to all configuration properties:

```swift
public actor HorizontalCollectionConstants {
    // UI layout constants
    public static var itemSize: CGFloat = 56
    public static var itemSpacing: CGFloat = 16
    
    // Animation and physics constants
    public static var selectionAnimationDuration: Double = 0.25
    public static var selectionAnimationDuringDrag: Double = 0.1
    // Additional properties...
    
    // Screen dimensions helper - marked nonisolated for sync access
    @MainActor
    public static var screenWidth: CGFloat {
        #if os(iOS)
        UIScreen.main.bounds.width
        #else
        1080 // Default for non-iOS platforms
        #endif
    }
    
    public static func configure(...) async {
        // Thread-safe configuration
    }
}
```

This actor provides:
- Thread-safe configuration properties
- Async configuration methods
- Safe access patterns for concurrent environments
- Screen-size aware layout calculations

## Key Design Decisions

### Concurrency Safety

The package uses Swift's actor model to ensure thread safety:

1. **Actor-Isolated Configuration**: The `HorizontalCollectionConstants` is implemented as an actor, ensuring that all mutable state is properly isolated.

2. **MainActor ViewModel**: The `CenteredScrollViewModel` is explicitly annotated with `@MainActor` to ensure UI updates occur on the main thread.

3. **Concurrency-Safe Preference Key**: The `OffsetPreferenceKey` uses a computed property to avoid shared mutable state.

4. **Async Configuration API**: The package provides async methods for configuration that respect Swift's structured concurrency model.

5. **Caching for UI Performance**: The main view caches actor values to minimize async calls in the UI layer.

### Enhanced Scrolling Physics

The package implements two scrolling behavior modes:

1. **Standard Mode**: Simple selection and centering for basic use cases.
2. **Target Content Offset Mode**: Enhanced physics that mimics UICollectionView's native feel with better velocity-based targeting.

The enhanced scrolling uses:

- Velocity tracking with smoothing for natural feel
- Momentum detection to prevent interrupting natural scrolls
- Power curve scaling to allow faster scrolling for longer distances
- Direction correction for edge cases like stopping between items
- Adaptive animation timing based on distance and velocity

### Generic Design

The collection is designed to work with any `Identifiable` model type:

```swift
public struct CenteredHorizontalCollection<T: Identifiable>: View {
    // ...
}
```

This allows users to:
- Use their own model types without adaptation
- Customize item appearance completely with a view builder
- Integrate seamlessly with existing SwiftUI code
- Support any ID type via consistent hashing for non-Int IDs

### Configurability

The package uses a central actor-based configuration object (`HorizontalCollectionConstants`) that allows users to:

- Adjust visual parameters (item size, spacing)
- Fine-tune scrolling physics (velocity thresholds, animation duration)
- Enable/disable debugging
- Switch between scrolling behavior modes
- Customize animation timing and behavior

All configuration access is thread-safe through the actor model.

## Implementation Challenges and Solutions

### Thread Safety and Concurrency

Challenge: Managing shared mutable state in a concurrent environment.

Solution:
- Used Swift's actor model to isolate mutable state
- Implemented `nonisolated` properties where appropriate for synchronous access
- Created async configuration APIs that respect Swift's concurrency model
- Cached actor values in the UI layer to minimize performance impact
- Used `@MainActor` annotation for UI-specific code
- Applied structured concurrency patterns for asynchronous operations

### Accurate Velocity Measurement

Challenge: SwiftUI doesn't provide direct access to scroll velocity.

Solution: Implemented a custom velocity tracking system that:
- Samples position changes over time
- Applies smoothing for natural feel
- Correctly handles direction changes
- Scales appropriately for different device sizes
- Tracks drag direction for improved targeting decisions

### Preventing Correction Loops

Challenge: Frequent correction attempts can lead to visual jitter.

Solution:
- Implemented cooldown periods between corrections
- Tracked correction attempts and limited maximum tries
- Added thresholds to only correct when necessary
- Used debounce timers to wait for natural scrolling to complete
- Applied adaptive correction sensitivity based on context

### Natural Momentum Scrolling

Challenge: Interrupting momentum feels unnatural to users.

Solution:
- Added momentum detection to avoid interrupting natural deceleration
- Implemented adaptive targeting based on velocity magnitude
- Used velocity-sensitive animation timing for smoother transitions
- Applied direction heuristics for better "between items" decisions
- Implemented power curve scaling for more natural scrolling over distances

### External Selection Binding

Challenge: Synchronizing internal selection state with external bindings without causing feedback loops.

Solution:
- Used Combine publishers to monitor selection changes
- Implemented debouncing to prevent rapid selection changes
- Added special handling for programmatic selections
- Maintained selection state correctly during scrolling operations
- Provided consistent selection behavior across scrolling modes

## Performance Considerations

The implementation is optimized for:

- Minimal view updates (using `isSelected` value changes)
- Efficient preference key usage (only tracking position, not appearance)
- Memory efficiency (no strong reference cycles or excessive state)
- CPU efficiency (using throttled updates for calculations)
- Concurrency safety (using Swift's actor model to isolate mutable state)
- Adaptive correction (only applying corrections when necessary)
- Selective animation (using animation only where needed)
- Efficient layout calculation (caching screen dimensions)

## Future Enhancements

Potential improvements for future versions:

1. Vertical collection mode with the same physics and selection behavior
2. Carousel/infinite scrolling mode for continuous cycling through items
3. Pagination support with customizable page sizes
4. Snap point customization for irregular spacing
5. Improved accessibility with VoiceOver and dynamic type support
6. Interactive spring physics for more engaging interactions
7. Gesture customization (pinch-to-zoom, rotate, etc.)
8. Actor-based distributed configuration for multi-window scenarios
9. Improved animation customization API
10. Cross-platform optimizations for macOS, tvOS, and visionOS
