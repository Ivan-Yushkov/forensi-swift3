//
//  ActivateAccountViewController.swift
//  ForensiDoc

import UIKit

open class ActivateAccountViewController: BaseViewController {
    
    @IBOutlet var activationCode: UITextField!
    
    override var viewType: ViewType {
        get {
            return .activateAccountView
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = kDialogTitleActivateAccount
    }
    
    override open func didBecomeActive() {
        super.didBecomeActive()
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        self.prepopulateAccountActivationCode()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let user = DataManager.sharedInstance.user()
        if user.activated {
            self.activationCode.text = ""
        }
    }
    
    func prepopulateAccountActivationCode() {
        let activationCode = DataManager.sharedInstance.helperData().accountActivationCode
        if activationCode.count > 0 {
            DataManager.sharedInstance.helperData().accountActivationCode = ""
            self.activationCode.text = activationCode
        }
        
        if let activationCode = self.activationCode.text {
            if activationCode.count > 0 {
                self.activateAccountTapped(self)
            }
        }
    }
    
    @IBAction func activateAccountTapped(_ sender: AnyObject) {
        if let activationCode = self.activationCode.text {
            if activationCode.count == 0 {
                self.displayErrorAlert(kErrorTitle, messages: [kPleaseEnterActivationCode])
            } else {
                var task: URLSessionTask? = nil
                AlertHelper.DisplayProgress(self, title: kPleaseWaitTitle, messages: [], cancelCallback: { () -> Void in
                    task?.cancel()
                    return
                    }, onDisplay: { (alert) -> Void in
                        task = NetworkingManager.sharedInstance.activateAccount(DataManager.sharedInstance.user().userName, activationCode: activationCode, callback: { (response: Result<BaseResponse>) -> () in
                            AlertHelper.CloseDialog(alert){
                                self.processBaseResponse(response, successfullCallback: { (response: BaseResponse) -> () in
                                    DataManager.sharedInstance.user().activated = true
                                    let user = DataManager.sharedInstance.user()
                                    if user.hasCreatedPasscode() {
                                        BitmelterAccountManager.sharedInstance.triggerSuccessfullAccountActivation()
                                    } else {
                                        //Create passcode
                                        let createPasscodeView: CreatePasscodeViewController? = nil
                                        self.navigateToView(createPasscodeView)
                                    }
                                })
                            }
                        })
                })
            }
        }
    }
    
    
    @IBAction func sendNewActivationCodeTapped(_ sender: AnyObject) {
        var task: URLSessionTask? = nil
        AlertHelper.DisplayProgress(self, title: kPleaseWaitTitle, messages: [], cancelCallback: { () -> Void in
            task?.cancel()
            return
            }) { (alert) -> Void in
                task = NetworkingManager.sharedInstance.sendNewActivationCode(DataManager.sharedInstance.user().userName, callback: { (response: Result<BaseResponse>) -> () in
                    AlertHelper.CloseDialog(alert){
                        self.processBaseResponse(response, successfullCallback: { (response: BaseResponse) -> () in
                            self.displayConfirmationAlert(kNewActivationCodeSentOK)
                        })
                    }
                })
        }
    }
}
