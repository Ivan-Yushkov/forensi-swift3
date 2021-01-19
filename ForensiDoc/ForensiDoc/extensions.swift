//
//  extensions.swift
//  ForensiDoc
//
//  Created by   admin on 18.01.2021.
//  Copyright © 2021 Bitmelter Ltd. All rights reserved.
//

import Foundation

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
