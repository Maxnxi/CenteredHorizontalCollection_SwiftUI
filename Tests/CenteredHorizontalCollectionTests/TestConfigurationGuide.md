# Test Configuration Guide for CenteredHorizontalCollection

This document provides instructions for setting up and running tests for the CenteredHorizontalCollection package.

## Test Structure

The test suite consists of several test files:

1. `CenteredHorizontalCollectionTests.swift` - Basic unit tests for the package
2. `CenteredHorizontalCollectionUITests.swift` - UI tests using ViewInspector
3. `CenteredHorizontalCollectionPerformanceTests.swift` - Performance and memory tests

## Requirements

Before running the tests, you need to ensure you have the proper dependencies:

1. Xcode 15.0 or higher
2. Swift 5.9 or higher
3. ViewInspector package (for UI tests)

## ViewInspector Setup

The UI tests rely on ViewInspector, which is not included in the main package dependencies. Follow these steps to add it to your test target:

1. Add ViewInspector to your Package.swift file:

```swift
// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "CenteredHorizontalCollection",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "CenteredHorizontalCollection",
            targets: ["CenteredHorizontalCollection"]),
    ],
    dependencies: [
        // Add ViewInspector for testing
        .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "CenteredHorizontalCollection",
            dependencies: [],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "CenteredHorizontalCollectionTests",
            dependencies: [
                "CenteredHorizontalCollection",
                .product(name: "ViewInspector", package: "ViewInspector") // Add ViewInspector dependency here
            ]),
    ],
    swiftLanguageModes: [.v5]
)
```

2. Update the package to fetch the new dependency:

```bash
swift package update
```

## Running Tests

### From Xcode

1. Open the package in Xcode
2. Go to Product > Test or use the shortcut ⌘U
3. All tests will run, and results will be displayed in the Test Navigator

### From Command Line

```bash
# Run all tests
swift test

# Run specific test target
swift test --target CenteredHorizontalCollectionTests

# Run with verbose output
swift test -v
```

## Performance Testing

The performance tests are designed to measure:

1. Initialization time with different numbers of items
2. Rendering performance with simple vs. complex item views