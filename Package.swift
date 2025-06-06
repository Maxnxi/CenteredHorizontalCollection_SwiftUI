// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "CenteredHorizontalCollection",
			targets: ["CenteredHorizontalCollection"]),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		// No external dependencies
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		.target(
			name: "CenteredHorizontalCollection",
			dependencies: [],
			resources: [
			],
			swiftSettings: [
				.enableExperimentalFeature("StrictConcurrency")
			]
		),
		.testTarget(
			name: "CenteredHorizontalCollectionTests",
			dependencies: ["CenteredHorizontalCollection"]),
	],
	swiftLanguageModes: [.v5]
)
