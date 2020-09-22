//
//  RegisterForNewAccountViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 18/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import UIKit

open class RegisterForNewAccountViewController: BaseViewController {
    
    @IBOutlet var onePasswordButton: UIButton!
    @IBOutlet var registrationEmail: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        OnePasswordHelper.Set1PasswordButton(self.onePasswordButton)
        self.title = kDialogTitleNewAccount
    }
    
    @IBAction func onePasswordTapped(_ sender: AnyObject) {
        OnePasswordHelper.SaveLogin(self, username: self.registrationEmail, password: self.password, passwordAgain: self.confirmPassword, errorAlert: self.displayErrorAlert)
    }
    
    @IBAction func createAccountTouched(_ sender: AnyObject) {
        var errorMessages:[String] = Array<String>()
        
        if let registrationEmail = self.registrationEmail.text, let password = self.password.text, let confirmPassword = self.confirmPassword.text {
            
            errorMessages += self.processEmailLogic(registrationEmail)
            errorMessages += self.processPasswordLogic(password, confirmPassword: confirmPassword)
            
            let hasAnyErrorMessages = self.hasAnyErrorMessages(errorMessages)
            
            if !hasAnyErrorMessages {
                var sessionTask: URLSessionTask? = nil
                AlertHelper.DisplayProgress(self, title: kPleaseWaitTitle, messages: [""], cancelCallback: { () -> Void in
                    sessionTask?.cancel()
                    return
                    }, onDisplay: { (alert) -> Void in
                        sessionTask = NetworkingManager.sharedInstance.register(registrationEmail, password: password, firstName: "", lastName: "", callback: { (response: Result<BaseResponse>) -> () in
                            AlertHelper.CloseDialog(alert){
                                self.processBaseResponse(response, successfullCallback: { (response: BaseResponse) -> () in
                                    DataManager.sharedInstance.user().userName = registrationEmail
                                    DispatchQueue.main.async(execute: {
                                        let activateNewAccount: ActivateAccountViewController? = nil;
                                        self.navigateToView(activateNewAccount)
                                    })
                                })
                            }
                        })
                })
            }
        }
    }
}
