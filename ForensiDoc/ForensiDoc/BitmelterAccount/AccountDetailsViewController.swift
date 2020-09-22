//
//  AccountDetailsViewController.swift
//  ForensiDoc

import Foundation

open class AccountDetailsViewController: BaseViewController {
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var newEmail: UITextField!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = kDialogTitleEditAccount
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(AccountDetailsViewController.saveButtonTapped(_:)))
        self.navigationItem.setRightBarButton(saveButton, animated: true)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user = DataManager.sharedInstance.user()
        self.newEmail.text = user.userName
        self.firstName.text = user.firstName
        self.lastName.text = user.lastName
    }
    
    func saveButtonTapped(_ sender: AnyObject) {
        var errorMessages:[String] = Array<String>()
        
        if let newEmail = self.newEmail.text {
            errorMessages += self.processEmailLogic(newEmail)
            
            let hasAnyErrorMessages = self.hasAnyErrorMessages(errorMessages)
            
            if !hasAnyErrorMessages {
                var sessionTask: URLSessionTask? = nil
                AlertHelper.DisplayProgress(self, title: kPleaseWaitTitle, messages: [""], cancelCallback: { () -> Void in
                    sessionTask?.cancel()
                    return
                    }, onDisplay: { (alert) -> Void in
                        if let firstName = self.firstName.text, let lastName = self.lastName.text {
                            let user = DataManager.sharedInstance.user()
                            sessionTask = NetworkingManager.sharedInstance.changeAccountDetails(user.userName, newEmail: newEmail, firstName: firstName, lastName: lastName, callback: { (response: Result<BaseResponse>) -> () in
                                AlertHelper.CloseDialog(alert){
                                    self.processBaseResponse(response, successfullCallback: { (response: BaseResponse) -> () in
                                        user.userName = newEmail
                                        user.firstName = firstName
                                        user.lastName = lastName
                                        self.displayConfirmationAlert("Done", callback: { () -> Void in
                                            self.navigationController?.popViewController(animated: true)
                                            return
                                        })
                                    })
                                }
                            })
                        }
                })
            }
        }
    }
}
