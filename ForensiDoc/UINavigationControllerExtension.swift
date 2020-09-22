//
//  UINavigationControllerExtension.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 24/02/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

import Foundation

extension UINavigationController {
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if ViewsHelpers.IsiPad() {
            return [.landscapeLeft,.landscapeRight]
        }
        return [.portrait, .portraitUpsideDown]
    }
    
    open override var shouldAutorotate : Bool {
        return true
    }
}
