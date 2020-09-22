//
//  RegisterForNewAccountViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 18/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import UIKit
import BitmelterAlerts

public class RegisterForNewAccountViewController: BaseViewController {
    
    @IBOutlet var onePasswordButton: UIButton!
    @IBOutlet var registrationEmail: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmPassword: UITextField!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        OnePasswordHelper.Set1PasswordButton(self.onePasswordButton)
        self.title = kDialogTitleNewAccount
    }
    
    @IBAction func onePasswordTapped(sender: AnyObject) {
        OnePasswordHelper.SaveLogin(self, username: self.registrationEmail, password: self.password, passwordAgain: self.confirmPassword, errorAlert: self.displayErrorAlert)
    }
    
    @IBAction func createAccountTouched(sender: AnyObject) {
        var errorMessages:[String] = Array<String>()
        
        if let registrationEmail = self.registrationEmail.text, password = self.password.text, confirmPassword = self.confirmPassword.text {
            
            errorMessages += self.processEmailLogic(registrationEmail)
            errorMessages += self.processPasswordLogic(password, confirmPassword: confirmPassword)
            
            let hasAnyErrorMessages = self.hasAnyErrorMessages(errorMessages)
            
            if !hasAnyErrorMessages {
                var sessionTask: NSURLSessionTask? = nil
                AlertHelper.DisplayProgress(self, title: kPleaseWaitTitle, messages: [""], callback: { () -> Void in
                    sessionTask?.cancel()
                    return
                    }, onDisplay: { (alert) -> Void in
                        sessionTask = NetworkingManager.sharedInstance.register(registrationEmail, password: password, firstName: "", lastName: "", callback: { (response: Result<BaseResponse>) -> () in
                            AlertHelper.CloseDialog(alert){
                                self.processBaseResponse(response, successfullCallback: { (response: BaseResponse) -> () in
                                    DataManager.sharedInstance.user().userName = registrationEmail
                                    dispatch_async(dispatch_get_main_queue(), {
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
