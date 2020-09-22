//
//  OnePasswordHelper.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 02/12/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

class OnePasswordHelper {
    class func Set1PasswordButton(_ button: UIButton!) {
        button?.isHidden = !OnePasswordExtension.shared().isAppExtensionAvailable()
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
        
        OnePasswordExtension.shared().changePasswordForLogin(forURLString: kOnePasswordStoreLoginUrl, loginDetails: loginDetails, passwordGenerationOptions: passwordGenerationOptions, for: viewController, sender: viewController) { (loginDict: [AnyHashable: Any]!, error: NSError!) -> Void in
            if loginDict == nil {
                if let e = error {
                    if e.code != Int(AppExtensionErrorCodeCancelledByUser) {
                        errorAlert?(e)
                    }
                }
                return
            }
            
            let newPassword: String? = loginDict[AppExtensionPasswordKey] as? String
            if let np = newPassword {
                changedPassword?.text = np
                confirmChangedPassword?.text = np
            }
        } as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void
    }
    
    class func FindLogin(_ viewController: UIViewController, username: UITextField!, password: UITextField!, errorAlert: ((NSError) -> Void)?){
        OnePasswordExtension.shared().findLogin(forURLString: kOnePasswordStoreLoginUrl, for: viewController, sender: viewController) { (loginDict: [AnyHashable: Any]!, error: NSError!) -> Void in
            if loginDict == nil {
                if let e = error {
                    if e.code != Int(AppExtensionErrorCodeCancelledByUser) {
                        errorAlert?(e)
                    }
                }
                return
            }
            
            let storedUserName : String? = loginDict[AppExtensionUsernameKey] as? String
            let storedPassword : String? = loginDict[AppExtensionPasswordKey] as? String
            
            if let u = storedUserName {
                username?.text = u
            }
            if let p = storedPassword {
                password?.text = p
            }
        } as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void
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
        
        OnePasswordExtension.shared().storeLogin(forURLString: kOnePasswordStoreLoginUrl, loginDetails: newLoginDetails, passwordGenerationOptions: passwordGenerationOptions, for: viewController, sender: viewController) { (loginDict: [AnyHashable: Any]!, error: NSError!) -> Void in
            if loginDict == nil {
                if let e = error {
                    if e.code != Int(AppExtensionErrorCodeCancelledByUser) {
                        errorAlert?(e)
                    }
                }
                return
            }
            
            let newUserName : String? = loginDict[AppExtensionUsernameKey] as? String
            let newPassword : String? = loginDict[AppExtensionPasswordKey] as? String
            
            if let u = newUserName {
                username?.text = u
            }
            if let p = newPassword {
                password?.text = p
                passwordAgain?.text = p
            }
        } as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void as! ([AnyHashable : Any]?, Error?) -> Void
    }
}
