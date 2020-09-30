//
//  OnePasswordHelper.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 02/12/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

class OnePasswordHelper {
    
//    class func tet(viewController: UIViewController) {
//        OnePasswordExtension.shared().changePasswordForLogin(forURLString: "string", loginDetails: ["key": "value"], passwordGenerationOptions: [:], for: viewController, sender: viewController) { (dict, error) in
//            if let d = dict {
//                print(d)
//            } else {
//                
//            }
//            
//            if let e = error as NSError? {
//                print(e.code)
//            }
//        
//        }
//    }
//    
    class func Set1PasswordButton(_ button: UIButton) {
        button.isHidden = !OnePasswordExtension.shared().isAppExtensionAvailable()
    }
    
     class func ChangeLogin(_ viewController: UIViewController, username: String, oldPassword: String, changedPassword: UITextField!, confirmChangedPassword: UITextField!, errorAlert: ((NSError) -> Void)?) {
        
        let loginDetails: [String: String?] =
        [
            AppExtensionTitleKey: kOnePasswordTitleKey,
            AppExtensionUsernameKey: username, // 1Password will prompt the user to create a new item if no matching logins are found with this username.
            AppExtensionPasswordKey: changedPassword?.text,
            AppExtensionOldPasswordKey: oldPassword,
            AppExtensionNotesKey: kOnePasswordNotesKey,
        ]
        
        let passwordGenerationOptions =
        [
            AppExtensionGeneratedPasswordMinLengthKey : 6,
            AppExtensionGeneratedPasswordMaxLengthKey: 50
        ]
        
        OnePasswordExtension.shared().changePasswordForLogin(forURLString: kOnePasswordStoreLoginUrl, loginDetails: loginDetails, passwordGenerationOptions: passwordGenerationOptions, for: viewController, sender: viewController) { (loginDict, error)  in
            if loginDict == nil {
                if let error = error as NSError? {
                    if error.code != Int(AppExtensionErrorCodeCancelledByUser) {
                        errorAlert?(error)
                    }
                }
                return
            }
            
            let newPassword: String? = loginDict?[AppExtensionPasswordKey] as? String
            if let np = newPassword {
                changedPassword?.text = np
                confirmChangedPassword?.text = np
            }
        }
    }
   class func FindLogin(_ viewController: UIViewController, username: UITextField!, password: UITextField!, errorAlert: ((NSError) -> Void)?){
        OnePasswordExtension.shared().findLogin(forURLString: kOnePasswordStoreLoginUrl, for: viewController, sender: viewController) { (loginDict,  error)  in
            if loginDict == nil {
                if let error = error as NSError? {
                    if error.code != Int(AppExtensionErrorCodeCancelledByUser) {
                        errorAlert?(error)
                    }
                }
                return
            }
            
            let storedUserName : String? = loginDict?[AppExtensionUsernameKey] as? String
            let storedPassword : String? = loginDict?[AppExtensionPasswordKey] as? String
            
            if let u = storedUserName {
                username?.text = u
            }
            if let p = storedPassword {
                password?.text = p
            }
        }// as! ([AnyHashable : Any]?, Error?) -> Void
    }
    
    class func SaveLogin(_ viewController: UIViewController, username: UITextField!, password: UITextField!, passwordAgain: UITextField!, errorAlert: ((NSError) -> Void)?){
        let newLoginDetails : [ String : String?] =
        [
            AppExtensionTitleKey : kOnePasswordTitleKey,
            AppExtensionUsernameKey : username?.text,
            AppExtensionPasswordKey : password?.text,
            AppExtensionNotesKey : kSavedWithApp,
            AppExtensionSectionTitleKey : kAppTitle
        ]
        
        let passwordGenerationOptions =
        [
            AppExtensionGeneratedPasswordMinLengthKey : 6,
            AppExtensionGeneratedPasswordMaxLengthKey: 50
        ]
        
        OnePasswordExtension.shared().storeLogin(forURLString: kOnePasswordStoreLoginUrl, loginDetails: newLoginDetails, passwordGenerationOptions: passwordGenerationOptions, for: viewController, sender: viewController) { (loginDict, error) -> Void in
            if loginDict == nil {
                if let error = error as NSError? {
                    if error.code != Int(AppExtensionErrorCodeCancelledByUser) {
                        errorAlert?(error)
                    }
                }
                return
            }
            
            let newUserName : String? = loginDict?[AppExtensionUsernameKey] as? String
            let newPassword : String? = loginDict?[AppExtensionPasswordKey] as? String
            
            if let u = newUserName {
                username?.text = u
            }
            if let p = newPassword {
                password?.text = p
                passwordAgain?.text = p
            }
        }
    }
}
