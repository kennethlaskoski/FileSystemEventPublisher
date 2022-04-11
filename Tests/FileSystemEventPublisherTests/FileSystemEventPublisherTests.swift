import System
import XCTest
@testable import FileSystemEventPublisher

@available(macOS 11.0, *, iOS 14.0, *)
final class FileSystemEventPublisherTests: XCTestCase {
  func testReceive() {
    let id = UUID()
    let tmpURL = FileManager.default.temporaryDirectory
    let url = URL(fileURLWithPath: "\(id)", relativeTo: tmpURL)
    let tmp = try! FileDescriptor.open(tmpURL.path, .readOnly, options: .eventOnly)

    var received = DispatchSource.FileSystemEvent()
    XCTAssertTrue(received.isEmpty)

    let expectation = self.expectation(description: "receive")
    let cancellable = FileSystemEventPublisher.monitor(tmp, for: .all)
      .sink { event in
        received = event
        expectation.fulfill()
      }

    XCTAssertNoThrow(try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil))
    waitForExpectations(timeout: 0.01)

    XCTAssertTrue(received.contains(.write))

    cancellable.cancel()
  }
}
