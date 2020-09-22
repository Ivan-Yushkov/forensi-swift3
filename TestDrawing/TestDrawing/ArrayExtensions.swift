//
//  ArrayExtensions.swift
//  TestDrawing
//
//  Created by Andrzej Czarkowski on 05/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

extension Array{
    func find(includedElement: T -> Bool) -> Int? {
        for (idx, element) in enumerate(self) {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}