//
//  CSVFunctions.swift
//  The MUT
//
//  Created by Benjamin Whitis on 6/7/19.
//  Copyright © 2019 Levenick Enterprises, LLC. All rights reserved.
//

import Foundation
import Cocoa
import CSV

public class CSVManipulation {
    let popMan = popPrompt()
    let logMan = logManager()
    
    func copyZip() {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.title = "Location to save MUT Templates.zip"
        savePanel.prompt = "Save"
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "MUT Templates.zip"
        savePanel.allowedFileTypes = ["zip"]
        savePanel.begin { [self] (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                guard let saveURL = savePanel.url else {return}
                guard let sourceURL = Bundle.main.url(forResource: "MUT Templates", withExtension: "zip")
                    else {
                    self.logMan.writeLog(level: .error, logString: "Error with getting the URL of the README file.")
                        return
                    }
                let fileManager = FileManager.default
                do {
                    try fileManager.copyItem(at: sourceURL, to: saveURL)
                    logMan.writeLog(level: .info, logString: "Saving template zip file to \(savePanel.url!.absoluteString.description.replacingOccurrences(of: "file://", with: ""))")
                } catch {
                    logMan.writeLog(level: .error, logString: "Error copying the readme file to the templates directory.")
                }
            }
        }
    }

    func readCSV(pathToCSV: String, delimiter: UnicodeScalar) -> [[String]]{
        let stream = InputStream(fileAtPath: pathToCSV)!

        // Initialize the array
        var csvArray = [[String]]()
        let csv = try! CSVReader(stream: stream, delimiter: delimiter)

        // For each row in the CSV, append it to the end of the array
        while let row = csv.next() {
            csvArray = (csvArray + [row])
        }
        return csvArray
    }
}
