//
//  PasscodeViewBaseController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 04/12/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

public class PasscodeViewBaseController: BaseViewController {
    let passCodeLength = 4
    private var firstPassCode: String = ""
    private var secondPassCode: String = ""
    private var doingFirstPassCode: Bool = true
    
    @IBOutlet var passCodeValue: UITextField!
    @IBOutlet var enableTouchIdSwitch: UISwitch!
    @IBOutlet var touchIdView: UIView!
    
    var isSettingUpPasscode: Bool = true {
        willSet(newValue) {
            self.isSettingUpPasscode = newValue
        }
    }
    
    var isChangingPasscode: Bool {
        return false
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.touchIdView?.hidden =
            !isSettingUpPasscode ||
            !TouchIdHelper.CanUseTouchId()
        self.passCodeValue?.addTarget(self, action: Selector("passCodeValueChanged:"), forControlEvents: UIControlEvents.EditingChanged)
        if let spc = self.splitViewController {
            spc.preferredDisplayMode = .PrimaryHidden
        }
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.passCodeValue?.becomeFirstResponder()
    }
    
    @IBAction func touchIdSwitchValueChange(sender: AnyObject) {
        if let o = self.enableTouchIdSwitch?.on {
            DataManager.sharedInstance.user().usingTouchId = o
        }
    }
    
    func togleImage(tag: Int, imageName: String) {
        if let imageView = self.view.viewWithTag(tag) as? UIImageView {
            if let passCodeSetImg = UIImage(named: imageName) {
                imageView.image? = passCodeSetImg
            }
        }
    }
    
    private func clearImages(){
        for index in 1...self.passCodeLength {
            self.togleImage(index, imageName: "PasscodeNotSet")
        }
    }
    
    func passCodeValueChanged(sender: AnyObject) {
        if let t = self.passCodeValue?.text {
            togleImage(t.characters.count,imageName: "PasscodeSet")
            if doingFirstPassCode && t.characters.count == passCodeLength {
                firstPassCode = t
                self.passCodeValue?.text = ""
                if isSettingUpPasscode {
                    doingFirstPassCode = false
                    //Popup message to enter the passcode again
                    self.displayConfirmationAlert(kEnterYourPasscodeAgain, callback: { () -> Void in
                        self.clearImages()
                    })
                } else {
                    //Check if passcode matches the created one
                    if DataManager.sharedInstance.user().passCode == firstPassCode {
                        BitmelterAccountManager.sharedInstance.triggerSuccessfullPasscode()
                    } else {
                        //Popup message that passcode does not match and let user try again
                        firstPassCode = ""
                        self.displayConfirmationAlert(kIncorrectPasscode, callback: { () -> Void in
                            self.clearImages()
                        })
                    }
                }
            } else if t.characters.count == passCodeLength {
                secondPassCode = t
            }
        }
        
        if isSettingUpPasscode && firstPassCode.characters.count == passCodeLength && secondPassCode.characters.count == passCodeLength {
            doingFirstPassCode = true
            self.passCodeValue?.text = ""
            if firstPassCode == secondPassCode {
                DataManager.sharedInstance.user().passCode = firstPassCode
                self.displayConfirmationAlert(kPasscodeHasBeenSet, callback: { () -> Void in
                    //TODO:Go to to whatever screen should be next
                    let user = DataManager.sharedInstance.user()
                    user.passCode = self.firstPassCode
                    if self.isChangingPasscode {
                        self.goBack()
                    } else {
                        if user.localUserOnly {
                            BitmelterAccountManager.sharedInstance.triggerSuccessFullLogon()
                        } else {
                            let loginViewController: LoginViewController? = nil
                            self.navigateToView(loginViewController)
                        }
                    }
                })
            } else {
                firstPassCode = ""
                secondPassCode = ""
                self.displayErrorAlert([kPasscodesDoNotMatch], callback: { () -> Void in
                    self.clearImages()
                })
            }
        }
    }
}