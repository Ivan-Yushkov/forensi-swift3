//
//  DebugLog.swift
//  ForensiDoc

import Foundation

extension String {
    func appendLineToURL(_ fileURL: URL) throws {
        //try self + "\n".appendToURL(fileURL)
        try self.appendToURL(fileURL)
    }
    
    func appendToURL(_ fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.appendToURL(fileURL)
    }
}

extension Data {
    func appendToURL(_ fileURL: URL) throws {
        if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
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

open class DebugLog {
    open class func DLog(_ message: String, function: String = #function) {
        let formatter = DateFormatter()
        formatter.timeStyle = .long
        let timeString = formatter.string(from: Date())
        
        if let u = MiscHelpers.DebugLogNSURL() {
            do{
                try "\(timeString) \(function): \(message)".appendLineToURL(u as URL)
            } catch {
                
            }
        }
        
        #if DEBUG
            print("\(function): \(message)")
        #endif
    }
}
