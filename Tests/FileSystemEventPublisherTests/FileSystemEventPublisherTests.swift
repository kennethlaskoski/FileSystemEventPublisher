import System
import XCTest
@testable import FileSystemEventPublisher

@available(iOS 14.0, *)
let File = FileManager.default.temporaryDirectory

@available(macOS 11.0, *, iOS 14.0, *)
final class FileSystemEventPublisherTests: XCTestCase {
  func testReceive() {
    let tmp = FileManager.default.temporaryDirectory
    let expectation = self.expectation(description: "receive")

    var received = DispatchSource.FileSystemEvent()
    XCTAssertEqual(received.rawValue, 0)

    var fd = try! FileDescriptor.open(tmp.path, .readOnly, options: .eventOnly)
    XCTAssertEqual(close(fd.rawValue), 0)

    fd = try! FileDescriptor.open(tmp.path, .readOnly, options: .eventOnly)

    let cancellable = DispatchSource.publish(
      .all,
      at: fd
    ).sink { event in
      received = event
      expectation.fulfill()
    }

    let url = URL(fileURLWithPath: "\(UUID())", relativeTo: tmp)
    try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)

    waitForExpectations(timeout: 0.1, handler: nil)
    XCTAssertNotEqual(received.rawValue, 0)
    cancellable.cancel()
  }
}
