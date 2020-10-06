//
//  PasscodeViewBaseController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 04/12/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

open class PasscodeViewBaseController: BaseViewController {
    let passCodeLength = 4
    fileprivate var firstPassCode: String = ""
    fileprivate var secondPassCode: String = ""
    fileprivate var doingFirstPassCode: Bool = true
    
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
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.touchIdView?.isHidden =
            !isSettingUpPasscode ||
            !TouchIdHelper.CanUseTouchId()
        self.passCodeValue?.addTarget(self, action: #selector(PasscodeViewBaseController.passCodeValueChanged(_:)), for: UIControl.Event.editingChanged)
        if let spc = self.splitViewController {
            spc.preferredDisplayMode = .primaryHidden
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passCodeValue?.becomeFirstResponder()
    }
    
    @IBAction func touchIdSwitchValueChange(_ sender: AnyObject) {
        if let o = self.enableTouchIdSwitch?.isOn {
            DataManager.sharedInstance.user().usingTouchId = o
        }
    }
    
    func togleImage(_ tag: Int, imageName: String) {
        if let imageView = self.view.viewWithTag(tag) as? UIImageView {
            if let passCodeSetImg = UIImage(named: imageName) {
                imageView.image? = passCodeSetImg
            }
        }
    }
    
    fileprivate func clearImages(){
        for index in 1...self.passCodeLength {
            self.togleImage(index, imageName: "PasscodeNotSet")
        }
    }
    
    @objc func passCodeValueChanged(_ sender: AnyObject) {
        if let t = self.passCodeValue?.text {
            togleImage(t.count,imageName: "PasscodeSet")
            if doingFirstPassCode && t.count == passCodeLength {
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
            } else if t.count == passCodeLength {
                secondPassCode = t
            }
        }
        
        if isSettingUpPasscode && firstPassCode.count == passCodeLength && secondPassCode.count == passCodeLength {
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
