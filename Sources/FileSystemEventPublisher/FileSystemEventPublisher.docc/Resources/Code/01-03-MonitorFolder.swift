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
