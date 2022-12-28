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
// Level 0 - Error (Default)
// Level 1 - Warning
// Level 2 - Info
// Level 3 - Verbose

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
    
    // Fatal will always write
    func fatalWrite(logString: String) {
        createDirectory()
        let currentTime = generateCurrentTimeStamp()
        let logURL = libraryURL?.appendingPathComponent("MUT.log")
        let dateLogString = currentTime + " [FATAL ]: " + logString
        //NSLog("[INFO  ]: Writing to MUT log file: '\(logString)'.")
        do {
            try dateLogString.appendLineToURL(fileURL: logURL!)
        }
        catch {
            //NSLog("[ERROR ]: An error occured while writing to the Log. \(error).")
        }
    }
    
    // Error will always write
    func errorWrite(logString: String) {
        createDirectory()
        let currentTime = generateCurrentTimeStamp()
        let logURL = libraryURL?.appendingPathComponent("MUT.log")
        let dateLogString = currentTime + " [ERROR ]: " + logString
        //NSLog("[INFO  ]: Writing to MUT log file: '\(logString)'.")
        do {
            try dateLogString.appendLineToURL(fileURL: logURL!)
        }
        catch {
            //NSLog("[ERROR ]: An error occured while writing to the Log. \(error).")
        }
    }

    // Warn will write at levels 1 and higher
    func warnWrite(logString: String) {
        if logDefaults.integer(forKey: "LogLevel") >= 1 {
            createDirectory()
            let currentTime = generateCurrentTimeStamp()
            let logURL = libraryURL?.appendingPathComponent("MUT.log")
            let dateLogString = currentTime + " [WARN  ]: " + logString
            //NSLog("[INFO  ]: Writing to MUT log file: '\(logString)'.")
            do {
                try dateLogString.appendLineToURL(fileURL: logURL!)
            }
            catch {
                //NSLog("[ERROR ]: An error occured while writing to the Log. \(error).")
            }
        }
    }

    // Info will write at levels 2 and higher
    func infoWrite(logString: String) {
        if logDefaults.integer(forKey: "LogLevel") >= 2 {
            createDirectory()
            let currentTime = generateCurrentTimeStamp()
            let logURL = libraryURL?.appendingPathComponent("MUT.log")
            let dateLogString = currentTime + " [INFO  ]: " + logString
            //NSLog("[INFO  ]: Writing to MUT log file: '\(logString)'.")
            do {
                try dateLogString.appendLineToURL(fileURL: logURL!)
            }
            catch {
                //NSLog("[ERROR ]: An error occured while writing to the Log. \(error).")
            }
        }
    }
    
    
    // Verbose will write at levels 2 and higher
    func verboseWrite(logString: String) {
        if logDefaults.integer(forKey: "LogLevel") >= 3 {
            createDirectory()
            let currentTime = generateCurrentTimeStamp()
            let logURL = libraryURL?.appendingPathComponent("MUT.log")
            let dateLogString = currentTime + " [DEBUG ]: " + logString
            //NSLog("[INFO  ]: Writing to MUT log file: '\(logString)'.")
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
