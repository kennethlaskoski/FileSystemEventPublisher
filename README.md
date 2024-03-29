# FileSystemEventPublisher

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkennethlaskoski%2FFileSystemEventPublisher%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kennethlaskoski/FileSystemEventPublisher)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkennethlaskoski%2FFileSystemEventPublisher%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kennethlaskoski/FileSystemEventPublisher)

[![Swift](https://github.com/kennethlaskoski/FileSystemEventPublisher/actions/workflows/swift.yml/badge.svg)](https://github.com/kennethlaskoski/FileSystemEventPublisher/actions/workflows/swift.yml)
[![CircleCI](https://circleci.com/gh/kennethlaskoski/FileSystemEventPublisher/tree/develop.svg?style=svg)](https://circleci.com/gh/kennethlaskoski/FileSystemEventPublisher/tree/develop)
![GitHub](https://img.shields.io/github/license/kennethlaskoski/filesystemeventpublisher)

A publisher that emits events in the file system.

## Overview

The FileSystemEventPublisher framework wraps a [Combine Publisher](https://developer.apple.com/documentation/combine/publisher)
around a [DispatchSourceFileSystemObject](https://developer.apple.com/documentation/dispatch/dispatchsourcefilesystemobject), 
providing a modern high-level interface to an efficient way of monitoring filesystem events.

## Usage

A typealias and a function are all the exposed interface, the Combine framework provides all remaining functionality.

The publisher is created by a function with two parameters: a file and a set of events; this signature reflects the
underlying DispatchSource interface.

The first parameter is a mask containing events of interest. The set of events are defined by a typealias to 
[DispatchSoutce.FileSystemEvent](https://developer.apple.com/documentation/dispatch/dispatchsource/filesystemevent).
This type is also the Output of the created publisher, i.e., the type of values to be delivered to subscribers.

The second parameter is a [FileDescriptor](https://developer.apple.com/documentation/system/filedescriptor) pointing to an open file, folder or socket.

The package includes a playground with a short example code.
