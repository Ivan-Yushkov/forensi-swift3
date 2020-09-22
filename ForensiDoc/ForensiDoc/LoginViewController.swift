//
//  LoginViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 17/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import UIKit
import BitmelterAlerts

public class LoginViewController: BaseViewController {
    
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var onePasswordButton: UIButton!
    
    override var viewType: ViewType {
        get {
            return .LoginView
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        OnePasswordHelper.Set1PasswordButton(self.onePasswordButton)
        self.title = kDialogTitleSignIn
    }
    
    @IBAction func onePasswordGetDataTapped(sender: AnyObject) {
        OnePasswordHelper.FindLogin(self, username: emailAddress, password: password, errorAlert: self.displayErrorAlert)
    }
    
    @IBAction func login(sender: AnyObject){
        var errorMessages:[String] = Array<String>()
        
        if let emailAddress = self.emailAddress.text, password = self.password.text {
            if emailAddress.characters.count  == 0 {
                errorMessages.append(kEmailCannotBeEmpty)
            }else if emailAddress.isValidEmail() {
                errorMessages.append(kInvalidEmail)
            }
            
            if password.characters.count == 0 {
                errorMessages.append(kPasswordCannotBeEmpty)
            }
            
            let hasAnyErrorMessages = self.hasAnyErrorMessages(errorMessages)
            
            if !hasAnyErrorMessages {
                var task: NSURLSessionTask? = nil
                AlertHelper.DisplayProgress(self, title: kPleaseWaitTitle, messages: [], callback: { () -> Void in
                    task?.cancel()
                    return
                    }, onDisplay: { (alert) -> Void in
                        task = NetworkingManager.sharedInstance.login(emailAddress, password: password, callback: { (response: Result<LoginResponse>) -> () in
                            AlertHelper.CloseDialog(alert){
                                self.processBaseResponse(response, successfullCallback: { (loginResponse: LoginResponse) -> () in
                                    let user = DataManager.sharedInstance.user()
                                    user.logonToken = loginResponse.token
                                    user.userName = emailAddress
                                    BitmelterAccountManager.sharedInstance.triggerSuccessFullLogon()
                                })
                            }
                        })
                })
            }
        }
    }
    
    @IBAction func remindPassword(sender: AnyObject){
        if let emailAddress = self.emailAddress.text {
            
            if emailAddress.characters.count == 0 {
                displayErrorAlert(kErrorTitle, messages: [kEmailCannotBeEmpty])
            } else if !emailAddress.isValidEmail() {
                displayErrorAlert(kErrorTitle, messages: [kInvalidEmail, kPleaseEnterAValidEmailAddress])
            } else {
                DataManager.sharedInstance.helperData().emailForPasswordRest = emailAddress
                var task: NSURLSessionTask? = nil
                AlertHelper.DisplayProgress(self, title: kPleaseWaitTitle, messages: [], callback: { () -> Void in
                    task?.cancel()
                    return
                    }, onDisplay: { (alert) -> Void in
                        task = NetworkingManager.sharedInstance.requestPasswordReset(emailAddress, callback: { (response: Result<BaseResponse>) -> () in
                            AlertHelper.CloseDialog(alert){
                                self.processBaseResponse(response, successfullCallback: { (baseResponse: BaseResponse) -> () in
                                    let passwordResetViewController: PasswordResetViewController? = nil
                                    self.navigateToView(passwordResetViewController)
                                })
                            }
                        })
                })
            }
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
