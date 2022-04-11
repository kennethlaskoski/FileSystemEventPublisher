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

///
/// Events involving a change to a file system object.
///
public typealias Event = DispatchSource.FileSystemEvent

///
/// Creates a new publisher for monitoring file system events.
///
/// - Parameters:
///   - fileDescriptor: A file descriptor pointing to an open file or socket.
///   - eventMask: The set of events you want to monitor. For a list of possible values,
///   see [DispatchSource.FileSystemEvent](https://developer.apple.com/documentation/dispatch/dispatchsource/filesystemevent).
///
/// - Returns: A publisher that emits events occurring at the observed file.
///
public func monitor(_ fileDescriptor: FileDescriptor, for eventMask: Event) -> AnyPublisher<Event, Never> {
  Monitor(fileDescriptor, for: eventMask).eraseToAnyPublisher()
}

//@available(macOS 11.0, iOS 14.0, *)

/// A publisher that emits events in the file system.
private struct Monitor: Publisher {
  typealias Output = Event
  typealias Failure = Never

  private static let queue = DispatchQueue(
    label: "br.dev.sr.FileSystemEventPublisher",
    qos: .userInitiated,
    attributes: .concurrent
  )

  private let file: FileDescriptor
  private let mask: Event

  init(_ fileDescriptor: FileDescriptor, for eventMask: Event) {
    file = fileDescriptor
    mask = eventMask
  }

  func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Event {
    let subscription = Subscription<S>(of: mask, at: file, on: Monitor.queue)
    subscription.target = subscriber
    subscriber.receive(subscription: subscription)
  }
}

/// The subscription to receive file system events
private final class Subscription<Target: Subscriber>: Combine.Subscription where Target.Input == Event {
  var target: Target?

  private var source: DispatchSourceFileSystemObject!
  private func trigger(event: Event) {
    _ = target?.receive(event)
  }

  init(of events: Event, at file: FileDescriptor, on queue: DispatchQueue) {
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
}
