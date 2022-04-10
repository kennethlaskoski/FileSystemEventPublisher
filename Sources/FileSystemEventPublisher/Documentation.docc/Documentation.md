# ``FileSystemEventPublisher``

A publisher that emits events in the file system.

## Overview

The FileSystemEventPublisher framework wraps a [Combine Publisher](https://developer.apple.com/documentation/combine/publisher)
around a [DispatchSourceFileSystemObject](https://developer.apple.com/documentation/dispatch/dispatchsourcefilesystemobject), providing a
modern high-level interface to an efficient way of monitoring filesystem events.

The publisher is created by a function, with a mask defining events of interest and a file descriptor as parameters.
This function is the only exposed interface, the Copmbine framework provides all remaining functionality.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
