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

    var event = Event()
    XCTAssertTrue(event.isEmpty)

    let expectation = self.expectation(description: "Receive filesystem event")
    let cancellable = monitor(tmp, for: .all)
      .sink {
        event = $0
        expectation.fulfill()
      }

    XCTAssertNoThrow(try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil))
    waitForExpectations(timeout: Double.leastNonzeroMagnitude)

    XCTAssertTrue(event.contains(.write))

    cancellable.cancel()
  }
}
