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

//@available(macOS 11.0, iOS 14.0, *)

/// A publisher that emits events in the file system.
public struct FileSystemEventPublisher: Publisher {
  ///
  /// Creates a new publisher for monitoring file system events.
  ///
  /// - Parameters:
  ///   - eventMask: The set of events you want to monitor. For a list of possible values,
  ///   see [DispatchSource.FileSystemEvent](https://developer.apple.com/documentation/dispatch/dispatchsource/filesystemevent).
  ///   - fileDescriptor: A file descriptor pointing to an open file or socket.
  ///
  /// - Returns: A publisher that emits events occurring at the observed file.
  ///
  public static func publish(_ eventMask: FileSystemEvent = .all, at fileDescriptor: FileDescriptor) -> AnyPublisher<FileSystemEvent, Never> {
    FileSystemEventPublisher(of: eventMask, at: fileDescriptor).eraseToAnyPublisher()
  }

  /// The subscription to receive file system events
  private final class Subscription<Target: Subscriber>: Combine.Subscription where Target.Input == FileSystemEvent {
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

  public typealias FileSystemEvent = DispatchSource.FileSystemEvent
  public typealias Output = FileSystemEvent
  public typealias Failure = Never

  private static let queue = DispatchQueue(
    label: "br.com.tractrix.FileSystemEventPublisher",
    qos: .userInitiated,
    attributes: .concurrent
  )

  private let file: FileDescriptor
  private let mask: FileSystemEvent

  private init(of eventMask: FileSystemEvent, at fileDescriptor: FileDescriptor) {
    file = fileDescriptor
    mask = eventMask
  }

  public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == FileSystemEvent {
    let subscription = Subscription<S>(of: mask, at: file, on: FileSystemEventPublisher.queue)
    subscription.target = subscriber
    subscriber.receive(subscription: subscription)
  }
}
