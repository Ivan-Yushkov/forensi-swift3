//
//  OnePasswordHelper.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 02/12/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation

class OnePasswordHelper {
    class func Set1PasswordButton(button: UIButton!) {
        button?.hidden = !OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
    }
    
    class func ChangeLogin(viewController: UIViewController, username: String, oldPassword: String, changedPassword: UITextField!, confirmChangedPassword: UITextField!, errorAlert: ((NSError) -> Void)?) {
        
        let loginDetails: [String: String!] =
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
        
        OnePasswordExtension.sharedExtension().changePasswordForLoginForURLString(kOnePasswordStoreLoginUrl, loginDetails: loginDetails, passwordGenerationOptions: passwordGenerationOptions, forViewController: viewController, sender: viewController) { (loginDict: [NSObject : AnyObject]!, error: NSError!) -> Void in
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
        }
    }
    
    class func FindLogin(viewController: UIViewController, username: UITextField!, password: UITextField!, errorAlert: ((NSError) -> Void)?){
        OnePasswordExtension.sharedExtension().findLoginForURLString(kOnePasswordStoreLoginUrl, forViewController: viewController, sender: viewController) { (loginDict: [NSObject : AnyObject]!, error: NSError!) -> Void in
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
        }
    }
    
    class func SaveLogin(viewController: UIViewController, username: UITextField!, password: UITextField!, passwordAgain: UITextField!, errorAlert: ((NSError) -> Void)?){
        let newLoginDetails : [ String : String!] =
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
        
        OnePasswordExtension.sharedExtension().storeLoginForURLString(kOnePasswordStoreLoginUrl, loginDetails: newLoginDetails, passwordGenerationOptions: passwordGenerationOptions, forViewController: viewController, sender: viewController) { (loginDict: [NSObject : AnyObject]!, error: NSError!) -> Void in
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
        }
    }
}
