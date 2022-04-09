import System
import Foundation
import FileSystemEventPublisher

let id = UUID()
let tmpURL = FileManager.default.temporaryDirectory
let url = URL(fileURLWithPath: "\(id)", relativeTo: tmpURL)
let tmp = try! FileDescriptor.open(tmpURL.path, .readOnly, options: .eventOnly)

var received = DispatchSource.FileSystemEvent()

print(received)     // prints "FileSystemEvent(rawValue: 0)"

let cancellable = FileSystemEventPublisher.publish(at: tmp)
  .sink { event in
    received = event
  }

try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)

sleep(1)

print(received)     // prints "FileSystemEvent(rawValue: 18)"

cancellable.cancel()
