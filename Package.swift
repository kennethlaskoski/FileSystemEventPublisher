// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FileSystemEventPublisher",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "FileSystemEventPublisher",
      targets: ["FileSystemEventPublisher"]),
  ],
  targets: [
    .target(
      name: "FileSystemEventPublisher",
      dependencies: []),
    .testTarget(
      name: "FileSystemEventPublisherTests",
      dependencies: ["FileSystemEventPublisher"]),
  ]
)
