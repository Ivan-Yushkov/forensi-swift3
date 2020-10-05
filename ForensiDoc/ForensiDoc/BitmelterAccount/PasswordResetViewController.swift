//
//  PasswordResetViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 13/01/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation
import UIKit

open class PasswordResetViewController: BaseViewController {
    
    @IBOutlet var passwordResetCode: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    @IBOutlet var onePasswordButton: UIButton!
    
    override var viewType: ViewType {
        get {
            return .resetPasswordView
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        OnePasswordHelper.Set1PasswordButton(self.onePasswordButton)
        self.title = kDialogTitleChangePassword
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.prepopulatePasswordResetCode()
    }
    
    override open func didBecomeActive() {
        super.didBecomeActive()
        self.prepopulatePasswordResetCode()
    }
    
    func prepopulatePasswordResetCode() {
        let resetPasswordCode = DataManager.sharedInstance.helperData().resetPasswordCode
        if resetPasswordCode.count > 0 {
            DataManager.sharedInstance.helperData().resetPasswordCode = ""
            self.passwordResetCode.text = resetPasswordCode
        }
    }
    
    @IBAction func onePasswordButtonTouched(_ sender: AnyObject) {
        let emailForPasswordReset = DataManager.sharedInstance.helperData().emailForPasswordRest
        OnePasswordHelper.ChangeLogin(self, username: emailForPasswordReset, oldPassword: "", changedPassword: self.password, confirmChangedPassword: self.confirmPassword, errorAlert: self.displayErrorAlert)
    }
    
    @IBAction func createNewPasswordTouched(_ sender: AnyObject) {
        var errorMessages:[String] = Array<String>()
        
        if let passwordResetCode = self.passwordResetCode.text, let password = self.password.text, let confirmPassword = self.confirmPassword.text {
            
            if passwordResetCode.count < 1 {
                errorMessages.append(kPasswordResetCodeCannotBeEmpty)
            }
            
            errorMessages += self.processPasswordLogic(password, confirmPassword: confirmPassword)
            
            let hasAnyErrorMessages = self.hasAnyErrorMessages(errorMessages)
            
            if !hasAnyErrorMessages {
                //Change the password here
                var sessionTask: URLSessionTask? = nil
                AlertHelper.DisplayProgress(self, title: kPleaseWaitTitle, messages: [""], cancelCallback: { () -> Void in
                    sessionTask?.cancel()
                    return
                    }, onDisplay: { (alert) -> Void in
                        let emailForPasswordReset = DataManager.sharedInstance.helperData().emailForPasswordRest
                        sessionTask = NetworkingManager.sharedInstance.resetPassword(emailForPasswordReset, newPassword: password, resetCode: passwordResetCode, callback: { (baseResponse: Result<BaseResponse>) -> () in
                            AlertHelper.CloseDialog(alert, completion: { () -> Void in
                                self.processBaseResponse(baseResponse, successfullCallback: { (response: BaseResponse) -> () in
                                    BitmelterAccountManager.sharedInstance.triggerSuccessfullPasswordreset()
                                })
                            })
                        })
                })
            }
        }
    }
}
