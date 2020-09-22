//
//  StringExtensions.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 18/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

extension String {
    func isValidEmail() -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]*"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(self)
        return result
    }
}