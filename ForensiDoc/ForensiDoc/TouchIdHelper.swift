//
//  TouchIdHelper.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 01/12/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import Foundation
import LocalAuthentication

class TouchIdHelper {
    class func CanUseTouchId() -> Bool {
        if let _: AnyClass = NSClassFromString("LAContext") {
            var error : NSError? = nil
            var result: Bool = false
            
            if LAContext().canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
                result = true
            }
            
            if let _ = error {
                return false
            }
            return result
        }
        return false
    }
    
    class func AuthenticateWithTouchId(callback:(() -> Void)?, failureCallback: (() -> Void)?) {
        let context = LAContext()
        var error: NSError? = nil
        
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Logon using your fingerprint", reply: { (success, error) -> Void in
                if success {
                    callback?()
                } else {
                    failureCallback?()
                }
            })
        } else {
            failureCallback?()
        }
    }
}
