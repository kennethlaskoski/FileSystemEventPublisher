//
//  FileSystemEventPublisher.swift
//  FileSystemEventPublisher
//
//  Created by Kenneth Laskoski on 14/05/21.
//

import System
import Combine
import Foundation

@available(macOS 11.0, *, iOS 14.0, *)
private extension DispatchSource {
  class Subscription<Target: Subscriber>: Combine.Subscription where Target.Input == FileSystemEvent {
    var target: Target?

    private var source: DispatchSourceFileSystemObject!
    init(of eventMask: FileSystemEvent, for url: URL, on queue: DispatchQueue) {
      let fd = try! FileDescriptor.open(url.path, .readOnly, options: .eventOnly)
      source = DispatchSource.makeFileSystemObjectSource(
        fileDescriptor: fd.rawValue,
        eventMask: eventMask,
        queue: queue
      )
      source.setEventHandler {
        self.trigger(event: self.source.data)
      }
      source.setCancelHandler {
        try? fd.close()
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
  private static let queue = DispatchQueue(label: "br.com.tractrix.FileSystemEventPublisher", qos: .userInitiated, attributes: .concurrent)

  public static func publish(_ events: FileSystemEvent, for url: URL) -> FileSystemEventPublisher {
    FileSystemEventPublisher(of: events, for: url)
  }

  public struct FileSystemEventPublisher: Publisher {
    public typealias Output = FileSystemEvent
    public typealias Failure = Never

    let url: URL
    let eventSet: FileSystemEvent

    init(of events: FileSystemEvent, for url: URL) {
      self.url = url
      self.eventSet = events
    }

    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Never, S.Input == FileSystemEvent {
      let subscription = Subscription<S>(of: eventSet, for: url, on: queue)
      subscription.target = subscriber
      subscriber.receive(subscription: subscription)
    }
  }
}
