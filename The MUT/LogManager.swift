//
//  LogManager.swift
//  MUT
//
//  Created by Michael Levenick on 7/12/19.
//  Copyright © 2019 Levenick Enterprises, LLC. All rights reserved.
//

import Foundation
import Cocoa


public class logManager {

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
    
    func infoWrite(logString: String) {
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

    func warnWrite(logString: String) {
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
