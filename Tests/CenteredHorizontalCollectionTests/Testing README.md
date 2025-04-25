//
//  NewFeatureTests.swift
//  CenteredHorizontalCollection
//
//  Created by Maksim Ponomarev on 4/26/25.
//


# CenteredHorizontalCollection Testing Guide

This document provides instructions for running, maintaining, and extending the test suite for the CenteredHorizontalCollection package.

## Test Suite Overview

The test suite consists of several categories of tests:

1. **Unit Tests**: Testing individual components and functions
2. **Integration Tests**: Testing component interactions
3. **UI Tests**: Testing visual rendering and user interactions
4. **Performance Tests**: Benchmarking and memory analysis

## Setting Up for Testing

### Prerequisites

- Xcode 15.0+
- Swift 5.9+
- SwiftUI
- ViewInspector package (for UI tests)

### Adding ViewInspector

The UI tests use the ViewInspector package. Add it to your Package.swift:

```swift
dependencies: [
    // Other dependencies...
    .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.9.0"),
],
targets: [
    // Main targets...
    .testTarget(
        name: "CenteredHorizontalCollectionTests",
        dependencies: [
            "CenteredHorizontalCollection",
            .product(name: "ViewInspector", package: "ViewInspector")
        ]),
]
```

Then run:

```bash
swift package update
```

## Running Tests

### From Xcode

1. Open the package in Xcode
2. Go to Product > Test (⌘U)
3. View results in the Test Navigator

### From Command Line

```bash
# Run all tests
swift test

# Run specific test case
swift test --filter CenteredHorizontalCollectionTests

# Run with verbose output
swift test -v
```

### Focus on Specific Tests

To focus on a specific test during development, you can:

1. Click the diamond icon next to a test in Xcode to run just that test
2. Use `XCTSkipIf` to conditionally skip tests
3. Use `--filter` with the command line to run specific tests

## Test Types and Structure

### Core Unit Tests

- `CenteredHorizontalCollectionTests.swift`: Tests the main collection view
- `CenteredScrollViewModelTests.swift`: Tests the scroll view model logic
- `HorizontalCollectionConstantsTests.swift`: Tests configuration system
- `OffsetPreferenceKeyTests.swift`: Tests preference key functionality
- `ItemViewTests.swift`: Tests the sample item view implementation

### Integration Tests

- `CenteredHorizontalCollectionIntegrationTests.swift`: Tests component interactions
- `ScrollBehaviorModeTests.swift`: Tests scrolling behavior modes

### UI Tests

- `CenteredHorizontalCollectionUITests.swift`: Tests UI rendering and interactions

### Performance Tests

- `CenteredHorizontalCollectionPerformanceTests.swift`: Benchmarks and performance analysis

## Adding New Tests

When adding new features to the package, follow these guidelines:

1. Create unit tests for any new components or functions
2. Update integration tests if component interactions change
3. Update UI tests if visual appearance or interactions change
4. Run performance tests to ensure no regressions

### Test Template

```swift
import XCTest
@testable import CenteredHorizontalCollection
import SwiftUI

final class NewFeatureTests: XCTestCase {
    
    // Test initialization/setup
    func testNewFeatureInitialization() {
        // Arrange - Set up test environment
        
        // Act - Perform the action being tested
        
        // Assert - Verify expected outcomes
    }
    
    // Test functionality
    func testNewFeatureFunctionality() {
        // Arrange
        
        // Act
        
        // Assert
    }
    
    // Test edge cases
    func testNewFeatureEdgeCases() {
        // Arrange
        
        // Act
        
        // Assert
    }
}
```

## Testing Best Practices

1. **Use the AAA pattern**: Arrange, Act, Assert for clear test structure
2. **Isolate tests**: Each test should be independent and not rely on other tests
3. **Reset state**: Always reset state between tests using `setUp()` and `tearDown()`
4. **Test edge cases**: Include tests for empty collections, extreme values, etc.
5. **Mock dependencies**: Use mocks for external dependencies like GeometryProxy
6. **Test concurrency**: Test actor-based code with multiple concurrent tasks
7. **Restore original values**: When changing global state, always restore original values

## Debugging Tests

### Common Issues

1. **Actor isolation warnings**: Ensure actor-isolated properties are accessed correctly
2. **Asynchronous testing issues**: Use expectations for async code testing
3. **SwiftUI environment issues**: Set up the correct environment for UI tests

### Debugging Tools

1. **XCTAttachment**: Attach screenshots or data to test reports
2. **ViewInspector**: Inspect the structure of SwiftUI views
3. **XCTContext**: Add additional context to test runs

## Performance Testing

When running performance tests:

1. Run on a consistent device/simulator for comparable results
2. Close other applications to minimize interference
3. Run multiple times and look for consistent patterns
4. Baseline measurements for future comparison

## Test Maintenance

1. **Update tests with features**: Keep tests in sync with implementation changes
2. **Clean up obsolete tests**: Remove tests for removed features
3. **Refactor for readability**: Keep test code clean and maintainable
4. **Review coverage reports**: Identify areas needing additional testing

## Additional Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [ViewInspector Documentation](https://github.com/nalexn/ViewInspector)
- [Swift Package Manager Testing](https://github.com/apple/swift-package-manager/blob/main/Documentation/Usage.md#testing)
- [SwiftUI Testing Best Practices](https://www.swiftbysundell.com/articles/testing-swiftui-views/)