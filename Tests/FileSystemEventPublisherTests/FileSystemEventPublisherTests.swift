import XCTest
@testable import FileSystemEventPublisher

@available(iOS 14.0, *)
let File = FileManager.default.temporaryDirectory

@available(macOS 11.0, *, iOS 14.0, *)
final class FileSystemEventPublisherTests: XCTestCase {
  func test() {
    let cancellable = DispatchSource.publish(
      .all,
      for: FileManager.default.temporaryDirectory
    ).receive(on: RunLoop.main).sink { event in
      print(event)
    }
    cancellable.cancel()
    XCTAssertEqual(self, self)
  }
}
