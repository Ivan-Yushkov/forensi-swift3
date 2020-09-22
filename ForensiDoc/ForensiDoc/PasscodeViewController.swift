//
//  PasscodeViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 04/12/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

public class PasscodeViewController: PasscodeViewBaseController {
    override var viewType: ViewType {
        get {
            return .PasscodeView
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.isSettingUpPasscode = false
        self.title = kDialogTitlePasscode
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if TouchIdHelper.CanUseTouchId() {
            TouchIdHelper.AuthenticateWithTouchId({ () -> Void in
                BitmelterAccountManager.sharedInstance.triggerSuccessfullPasscode()
            }, failureCallback: { () -> Void in
                
            })
        }
    }
    
    public class func GetPasscodeViewController(viewName: String) -> PasscodeViewController{
        let nibName = viewName.characters.count > 0 ? viewName : "PasscodeView"
        return PasscodeViewController(nibName:nibName, bundle:nil)
    }
    
    public class func GetPasscodeViewController() -> PasscodeViewController{
        return PasscodeViewController.GetPasscodeViewController("")
    }
}