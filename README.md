# FileSystemEventPublisher
A publisher that emits events in the file system.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkennethlaskoski%2FFileSystemEventPublisher%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kennethlaskoski/FileSystemEventPublisher)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkennethlaskoski%2FFileSystemEventPublisher%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kennethlaskoski/FileSystemEventPublisher)


## Example usage:

```
let id = UUID()
let tmpURL = FileManager.default.temporaryDirectory
let url = URL(fileURLWithPath: "\(id)", relativeTo: tmpURL)
let tmp = try! FileDescriptor.open(tmpURL.path, .readOnly, options: .eventOnly)

var received = DispatchSource.FileSystemEvent()

print(received)     // prints "FileSystemEvent(rawValue: 0)"

let cancellable = DispatchSource.publish(at: tmp)
  .sink { event in
    received = event
  }

try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
    
sleep(1)

print(received)     // prints "FileSystemEvent(rawValue: 18)"

cancellable.cancel()
```
