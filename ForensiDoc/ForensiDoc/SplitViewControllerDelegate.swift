//
//  SplitViewControllerDelegate.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 17/01/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

import Foundation
import UIKit

open class SplitViewControllerDelegate: NSObject, UISplitViewControllerDelegate{
    open func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {
        print("1")
    }
    
    open func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
        print("2")
        return .automatic
    }
    
    open func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
        print("3")
        return true
    }
    
    open func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        print("4")
        return false
    }
    
    open func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        print("5")
        return .none
    }
    
    open func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        print("6")
        return .none
    }
    
    open func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        print("7")
        return true
    }
    
    open func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        print("8")
        return .none
    }
    
    open func splitViewControllerSupportedInterfaceOrientations(_ splitViewController: UISplitViewController) -> UIInterfaceOrientationMask {
        print("9")
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            return [UIInterfaceOrientationMask.landscape]
        }
        return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.portraitUpsideDown]
    }
    
    open func splitViewControllerPreferredInterfaceOrientationForPresentation(_ splitViewController: UISplitViewController) -> UIInterfaceOrientation {
        print("10")
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            return UIInterfaceOrientation.landscapeRight
        }
        return UIInterfaceOrientation.portrait
    }
}
