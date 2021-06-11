# FileSystemEventPublisher

A publisher that tracks changes in the file system.

Example usage:

    let tmp = FileManager.default.temporaryDirectory
    fd = try! FileDescriptor.open(tmp.path, .readOnly, options: .eventOnly)
    let cancellable = DispatchSource.publish(
      .all,
      at: fd
    )
    .receive(on: RunLoop.main)
    .sink { event in
      print(event)
    }
    //.
    //.
    //.
    cancellable.cancel()
