//
//  LoginViewController.swift
//  ForensiDoc

import UIKit

open class LoginViewController: BaseViewController {
    
    @IBOutlet var emailAddress: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var onePasswordButton: UIButton!
    
    override var viewType: ViewType {
        get {
            return .loginView
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        OnePasswordHelper.Set1PasswordButton(self.onePasswordButton)
        self.title = kDialogTitleSignIn
    }
    
    @IBAction func onePasswordGetDataTapped(_ sender: AnyObject) {
        OnePasswordHelper.FindLogin(self, username: emailAddress, password: password, errorAlert: self.displayErrorAlert)
    }
    
    @IBAction func login(_ sender: AnyObject){
        var errorMessages:[String] = Array<String>()
        
        if let emailAddress = self.emailAddress.text, let password = self.password.text {
            if emailAddress.count  == 0 {
                errorMessages.append(kEmailCannotBeEmpty)
            }else if emailAddress.isValidEmail() {
                errorMessages.append(kInvalidEmail)
            }
            
            if password.count == 0 {
                errorMessages.append(kPasswordCannotBeEmpty)
            }
            
            let hasAnyErrorMessages = self.hasAnyErrorMessages(errorMessages)
            
            if !hasAnyErrorMessages {
                var task: URLSessionTask? = nil
                AlertHelper.DisplayProgress(self, title: kPleaseWaitTitle, messages: [], cancelCallback: { () -> Void in
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
    
    @IBAction func remindPassword(_ sender: AnyObject){
        if let emailAddress = self.emailAddress.text {
            
            if emailAddress.count == 0 {
                displayErrorAlert(kErrorTitle, messages: [kEmailCannotBeEmpty])
            } else if !emailAddress.isValidEmail() {
                displayErrorAlert(kErrorTitle, messages: [kInvalidEmail, kPleaseEnterAValidEmailAddress])
            } else {
                DataManager.sharedInstance.helperData().emailForPasswordRest = emailAddress
                var task: URLSessionTask? = nil
                AlertHelper.DisplayProgress(self, title: kPleaseWaitTitle, messages: [], cancelCallback: { () -> Void in
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
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
