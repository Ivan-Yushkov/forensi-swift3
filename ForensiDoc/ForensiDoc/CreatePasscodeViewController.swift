//
//  CreatePasscodeViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 01/12/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation
import LocalAuthentication

public class CreatePasscodeViewController : PasscodeViewBaseController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = kDialogTitleNewPasscode
    }
}