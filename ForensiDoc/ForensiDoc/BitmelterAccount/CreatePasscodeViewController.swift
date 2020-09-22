//
//  CreatePasscodeViewController.swift
//  ForensiDoc

import Foundation
import LocalAuthentication

open class CreatePasscodeViewController : PasscodeViewBaseController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = kDialogTitleNewPasscode
    }
}
