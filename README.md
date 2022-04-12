# ``FileSystemEventPublisher``

A publisher that emits events in the file system.

## Overview

The FileSystemEventPublisher framework wraps a [Combine Publisher](https://developer.apple.com/documentation/combine/publisher)
around a [DispatchSourceFileSystemObject](https://developer.apple.com/documentation/dispatch/dispatchsourcefilesystemobject), 
providing a modern high-level interface to an efficient way of monitoring filesystem events.

## Usage

A typealias and a function are all the exposed interface, the Combine framework provides all remaining functionality.

The publisher is created by a function with two parameters: a file and a set of events; this signature reflects the
underlying DispatchSource interface and was adopted for it's simplicity and performance.

The first parameter is a mask containing events of interest. The set of events are defined by a typealias to 
[DispatchSoutce.FileSystemEvent](https://developer.apple.com/documentation/dispatch/dispatchsource/filesystemevent).
This type is also the Output of the created publisher, i.e., the type of values to be delivered to subscribers.

The second parameter is a [FileDescriptor](https://developer.apple.com/documentation/system/filedescriptor) pointing to an open file, folder or socket.

The package includes a playground with a short example code.
