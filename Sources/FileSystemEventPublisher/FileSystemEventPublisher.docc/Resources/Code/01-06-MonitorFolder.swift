//
//  01-06-MonitorFolder.swift
//  
//
//  Created by Kenneth Laskoski on 15/04/22.
//

import System
import Foundation
import FileSystemEventPublisher

let tmpURL = FileManager.default.temporaryDirectory
let tmpFolder = try! FileDescriptor.open(tmpURL.path, .readOnly, options: .eventOnly)

let publisher = FileSystemEventPublisher.monitor(tmpFolder, for: .all)

var received = FileSystemEventPublisher.Event()
print(received)     // prints "FileSystemEvent(rawValue: 0)"

let cancellable = publisher
  .sink { event in
    received = event
  }

let id = UUID()
let newURL = URL(fileURLWithPath: "\(id)", relativeTo: tmpURL)
try! FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: false, attributes: nil)

sleep(1)
print(received)     // prints "FileSystemEvent(rawValue: 18)"

cancellable.cancel()
