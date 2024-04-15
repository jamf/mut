//
//  LogManager.swift
//  MUT
//
//  Created by Michael Levenick on 7/12/19.
//  Copyright © 2019 Levenick Enterprises, LLC. All rights reserved.
//

import Foundation
import Cocoa

// LOG LEVEL INFO
// Level 0 - Error
// Level 1 - Warning
// Level 2 - Info
// Level 3 - Verbose (Default)

public enum logLevel: String {
    case debug
    case info
    case warn
    case error
    case fatal
    
    public var severity: Int {
        switch self {
        case .debug: return 3
        case .info: return 2
        case .warn: return 1
        case .error: return 0
        case .fatal: return -1
        }
    }
}

public class logManager {
    
    let logDefaults = UserDefaults.standard
    let fileManager = FileManager.default
    let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
    let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("MUT")
    
    func openLog(){
        let pathToOpen = libraryDirectory!.resolvingSymlinksInPath().standardizedFileURL.absoluteString.replacingOccurrences(of: "file://", with: "") + "MUT/MUT.log"
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: pathToOpen)
        //print(pathToOpen)
    }
    
    func createDirectory(){
        if fileManager.fileExists(atPath: libraryURL!.path) {
            //NSLog("[INFO  ]: Template Directory already exists. Skipping creation.")
        } else {
            //NSLog("[INFO  ]: Template Directory does not exist. Creating.")
            do {
                try FileManager.default.createDirectory(at: libraryURL!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                //NSLog("[ERROR ]: An error occured while creating the Template Directory. \(error).")
            }
        }
    }
    
    func generateCurrentTimeStamp () -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return (formatter.string(from: Date()) as NSString) as String
    }
    
    func writeLog(level: logLevel, logString: String) {
        
        let logLabel = "[\(level.rawValue.uppercased().padding(toLength: 6, withPad: " ", startingAt: 0))]:"
        
        let defaultLogLevelInt: Int
        if let defaultLogLevelStringValue = logDefaults.string(forKey: "LogLevel"), let intValue = Int(defaultLogLevelStringValue) {
            defaultLogLevelInt = intValue
        } else {
            defaultLogLevelInt = 3
        }
        
        if defaultLogLevelInt >= level.severity {
            createDirectory()
            let currentTime = generateCurrentTimeStamp()
            let logURL = libraryURL?.appendingPathComponent("MUT.log")
            let dateLogString = currentTime + " " + logLabel + " " + logString
            //NSLog("[INFO  ]: Writing to MUT log file: '\(logString)'."
            do {
                try dateLogString.appendLineToURL(fileURL: logURL!)
            }
            catch {
                //NSLog("[ERROR ]: An error occured while writing to the Log. \(error).")
            }
        }
    }
}

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
