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
  static let queue = DispatchQueue(label: "br.com.tractrix.FileSystemEventPublisher", qos: .userInitiated, attributes: .concurrent)

  struct FileSystemEventPublisher: Publisher {
    public typealias Output = FileSystemEvent
    public typealias Failure = Never

    let file: FileDescriptor
    let mask: FileSystemEvent

    init(of events: FileSystemEvent, at fd: FileDescriptor) {
      file = fd
      mask = events
    }

    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Never, S.Input == FileSystemEvent {
      let subscription = Subscription<S>(of: mask, at: file, on: queue)
      subscription.target = subscriber
      subscriber.receive(subscription: subscription)
    }
  }

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
  public static func publish(_ events: FileSystemEvent, at fd: FileDescriptor) -> AnyPublisher<FileSystemEvent, Never> {
    FileSystemEventPublisher(of: events, at: fd).eraseToAnyPublisher()
  }
}
