//
//  UIImagePickerControllerExtension.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 15/02/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

import Foundation

extension UIImagePickerController {
    open override var shouldAutorotate : Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            return [UIInterfaceOrientationMask.landscape]
        }
        return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.portraitUpsideDown]
    }
    
    open override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        if(UI_USER_INTERFACE_IDIOM() == .pad) {
            return UIInterfaceOrientation.landscapeRight
        }
        return UIInterfaceOrientation.portrait
    }
}
