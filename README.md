# FileSystemEventPublisher

A publisher that tracks changes in the file system.

Example usage:

    let cancellable = DispatchSource.publish(
      .all,
      for: FileManager.default.temporaryDirectory
    ).receive(on: RunLoop.main).sink { event in
      print(event)
    }
    //.
    //.
    //.
    cancellable.cancel()
