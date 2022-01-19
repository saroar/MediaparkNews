// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "MediaparNewsSPM",
	platforms: [
		.iOS(.v14),
		.macOS(.v10_15)
	],

	products: [
		.library(name: "AppFeature", targets: ["AppFeature"]),
		.library(name: "NewsFeature", targets: ["NewsFeature"]),
		.library(name: "ArticleFeature", targets: ["ArticleFeature"]),
		.library(name: "SearchFeature", targets: ["SearchFeature"]),

		.library(name: "TopBarFeature", targets: ["TopBarFeature"]),
		.library(name: "SearchBarFeature", targets: ["SearchBarFeature"]),
		.library(name: "SearchBarFilter", targets: ["SearchBarFilter"]),
		.library(name: "SearchBarFilterSectors", targets: ["SearchBarFilterSectors"]),
		.library(name: "ArticleDetailsFeature", targets: ["ArticleDetailsFeature"]),

		.library(name: "NewsClient", targets: ["NewsClient"]),

		.library(name: "SwiftUIHelpers", targets: ["SwiftUIHelpers"]),

		.library(name: "Models", targets: ["Models"]),
		.library(name: "UserDefaultsClient", targets: ["UserDefaultsClient"]),
		.library(name: "TcaHelpers", targets: ["TcaHelpers"])
	],

	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.32.0"),
		.package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0")
	],

	targets: [
		.target(
			name: "AppFeature",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				 "SwiftUIHelpers", "NewsFeature", "SearchFeature"
			]
		),

		.target(
			name: "NewsFeature",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				 "SwiftUIHelpers", "NewsClient", "ArticleDetailsFeature",
				"TopBarFeature","ArticleFeature"
			]
		),

		.target(
			name: "ArticleFeature",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				 "SwiftUIHelpers", "Models"
			]
		),
		.target(
			name: "ArticleDetailsFeature",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				"SwiftUIHelpers"
			]
		),

		.target(
			name: "SearchFeature",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				 "SwiftUIHelpers", "TopBarFeature", "NewsClient", "Models", "UserDefaultsClient",
				"ArticleFeature", "SearchBarFeature", "SearchBarFilter", "SearchBarFilterSectors"
			]
		),

		.target(
			name: "TopBarFeature",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				 "SwiftUIHelpers", "SearchBarFeature"
			]
		),

		.target(
			name: "SearchBarFeature",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				 "SwiftUIHelpers", "SearchBarFilter", "TcaHelpers"
			]
		),

		.target(
			name: "SearchBarFilter",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				 "SwiftUIHelpers", "SearchBarFilterSectors", "TcaHelpers"
			]
		),

		.target(
			name: "SearchBarFilterSectors",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				 "SwiftUIHelpers", "UserDefaultsClient", "Models"
			]
		),

		.target(
			name: "NewsClient",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
				"Models"
			]
		),

		.target(
			name: "SwiftUIHelpers",
			dependencies: [
				.product(name: "Tagged", package: "swift-tagged")
			],
			resources: [
				.process("Fonts")
			]
		),

		.target(name: "Models"),

		.target(
			name: "UserDefaultsClient",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
			]
		),

		.target(
			name: "TcaHelpers",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
			]
		)
	]
)
