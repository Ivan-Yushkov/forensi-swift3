//
//  Signature.swift
//  ForensiDoc
//
//  Created by Иван Юшков on 02.02.2021.
//  Copyright © 2021 Bitmelter Ltd. All rights reserved.
//

import Foundation

struct Signature: Codable {
    
    let signature: String?
    let name: String?
    let address: String?
    let email: String?
    let telephone: String?
    let insurance: String?
    
    init(dictionary: [String: String]) {
        signature = dictionary["signature"]
        name = dictionary["name"]
        address = dictionary["address"]
        email = dictionary["email"]
        telephone = dictionary["telephone"]
        insurance = dictionary["insurance"]
    }
}
