//
//  DataManagerExtensions.swift
//  BitmelterAccount

import Foundation

extension DataManager {
    func processOpenUrl(_ url: URL, containing: String, assignTo: ((String) -> Void)?) -> Bool {
        if (url.absoluteString.lowercased().range(of: containing) != nil) {
             let lastPathComponent = url.lastPathComponent
                assignTo?(lastPathComponent)
                return true
        }
        return false
    }
}
