//
//  FileSystemEventPublisher.swift
//  FileSystemEventPublisher
//
//  Created by Kenneth Laskoski on 14/05/21.
//  Dedicated to Elisa Degrazia Xerxenesky
//

import System
import Combine
import Foundation

@available(macOS 11.0, *, iOS 14.0, *)
private extension DispatchSource {

  /// The file system event publisher.
  struct FileSystemEventPublisher: Publisher {
    private static let queue = DispatchQueue(label: "br.com.tractrix.FileSystemEventPublisher", qos: .userInitiated, attributes: .concurrent)

    typealias Output = FileSystemEvent
    typealias Failure = Never

    let file: FileDescriptor
    let mask: FileSystemEvent

    init(of events: FileSystemEvent, at fd: FileDescriptor) {
      file = fd
      mask = events
    }

    func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Never, S.Input == FileSystemEvent {
      let subscription = Subscription<S>(of: mask, at: file, on: FileSystemEventPublisher.queue)
      subscription.target = subscriber
      subscriber.receive(subscription: subscription)
    }
  }

  /// The subscription to receive file system events
  class Subscription<Target: Subscriber>: Combine.Subscription where Target.Input == FileSystemEvent {
    var target: Target?

    private var source: DispatchSourceFileSystemObject!
    init(of events: FileSystemEvent, at file: FileDescriptor, on queue: DispatchQueue) {
      source = DispatchSource.makeFileSystemObjectSource(
        fileDescriptor: file.rawValue,
        eventMask: events,
        queue: queue
      )
      source.setEventHandler {
        self.trigger(event: self.source.data)
      }
      source.setCancelHandler {
        try? file.close()
        self.source = nil
      }
      source.resume()
    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
      target = nil
      source.cancel()
    }

    func trigger(event: FileSystemEvent) {
      _ = target?.receive(event)
    }
  }
}

@available(macOS 11.0, *, iOS 14.0, *)
extension DispatchSource {
  /// Creates a new publisher for monitoring file-system events.
  /// - Parameters:
  ///   - events: The set of events to monitor. For a list of possible values, see DispatchSource.FileSystemEvent.
  ///   - fd: A file descriptor pointing to an open file or socket.
  /// - Returns: a publisher that triggers when events occur on the observed file
  public static func publish(_ events: FileSystemEvent = .all, at fd: FileDescriptor) -> AnyPublisher<FileSystemEvent, Never> {
    FileSystemEventPublisher(of: events, at: fd).eraseToAnyPublisher()
  }
}
