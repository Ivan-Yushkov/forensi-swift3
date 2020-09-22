//
//  BaseViewControllerPasswordExtensions.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 13/01/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation

extension BaseViewController {
    func processEmailLogic(_ email: String) -> [String] {
        var errorMessages = [String]()
        if email.characters.count == 0 {
            errorMessages.append(kEmailCannotBeEmpty)
        }else if !email.isValidEmail(){
            errorMessages.append(kInvalidEmail)
        }
        return errorMessages
    }
    
    func processPasswordLogic(_ password: String, confirmPassword: String) -> [String]{
        var errorMessages = [String]()
        
        if password != confirmPassword {
            errorMessages.append(kPasswordsAreNotTheSame)
        }
        
        if password.characters.count == 0 {
            errorMessages.append(kPasswordCannotBeEmpty)
        }
        
        if confirmPassword.characters.count == 0 {
            errorMessages.append(kConfirmationPasswordCannotBeEmpty)
        }
        
        return errorMessages
    }
    
    func hasAnyErrorMessages(_ errorMessages: [String]) -> Bool {
        var ret: Bool = true
        if errorMessages.count == 1 {
            displayErrorAlert(kErrorTitle, messages: errorMessages)
        } else if errorMessages.count > 1 {
            displayErrorAlert(kMultipleErrorsTitle, messages: errorMessages)
        } else {
            ret = false
        }
        return ret
    }
}
