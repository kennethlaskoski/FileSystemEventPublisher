import System
import Foundation
import FileSystemEventPublisher

// First we declare a varialble to store received events
var received = FileSystemEventPublisher.Event()
// Initially, we don't have any event
assert(received.isEmpty)
print(received)     // prints "FileSystemEvent(rawValue: 0)"

// Then we get the system's tmp folder url
let tmpURL = FileManager.default.temporaryDirectory
// And a file descriptor referencing it
let tmpFileDescriptor = try! FileDescriptor.open(tmpURL.path, .readOnly, options: .eventOnly)

// Now we can get a publisher to monitor the tmp folder
let publisher = FileSystemEventPublisher.monitor(tmpFileDescriptor, for: .all)

// When events arrive,
// we update our variable
let cancellable = publisher.sink { received = $0 }

// We create a new folder
let id = UUID()
let url = URL(fileURLWithPath: "\(id)", relativeTo: tmpURL)
try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)

// And this is reflected in our variable
assert(received.contains(.write))
print(received)     // prints "FileSystemEvent(rawValue: 18)"

// Finally, we cancel the subscription
// which will close the file descriptor
cancellable.cancel()
