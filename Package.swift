// swift-tools-version:6.0

import PackageDescription

let package = Package(
	name: "XKPhotoScrollView",
	platforms: [
		.iOS(.v15),
	],
	products: [
		.library(name: "XKPhotoScrollView", targets: ["XKPhotoScrollView"]),
	],
	targets: [
		.target(name: "XKPhotoScrollView"),
		.testTarget(name: "XKPhotoScrollViewTests", dependencies: ["XKPhotoScrollView"]),
	]
)
