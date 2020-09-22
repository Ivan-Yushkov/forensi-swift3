//
//  DataManagerExtensions.swift
//  BitmelterAccount
//
//  Created by Andrzej Czarkowski on 23/02/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation

extension DataManager {
    func processOpenUrl(url: NSURL, containing: String, assignTo: ((String) -> Void)?) -> Bool {
        if (url.absoluteString.lowercaseString.rangeOfString(containing) != nil) {
            if let lastPathComponent = url.lastPathComponent {
                assignTo?(lastPathComponent)
                return true
            }
        }
        return false
    }
}
