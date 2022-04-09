// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FileSystemEventPublisher",
  platforms: [
    .macOS(.v11),
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "FileSystemEventPublisher",
      targets: ["FileSystemEventPublisher"]
    ),
  ],
  targets: [
    .target(
      name: "FileSystemEventPublisher",
      dependencies: []
    ),
    .testTarget(
      name: "FileSystemEventPublisherTests",
      dependencies: ["FileSystemEventPublisher"]
    ),
  ]
)
