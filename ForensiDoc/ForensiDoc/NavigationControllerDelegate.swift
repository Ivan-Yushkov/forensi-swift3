//
//  NavCDelegate.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 19/01/2015.
//  Copyright (c) 2015 Bitmelter Ltd. All rights reserved.
//

import Foundation
import UIKit


class NavigationControllerDelegate:NSObject, UINavigationControllerDelegate {
    var counter: Int = 0
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        counter += 1
        NSLog("wilShowViewController %@ %d", viewController.description, counter)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        counter -= 1
        NSLog("didShowViewController %@ %d", viewController.description, counter)
    }
    
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if fromVC is BaseViewController
        {
            let baseViewController = fromVC as! BaseViewController
            
            if !baseViewController.HandlesDetailViewController() && ViewsHelpers.IsiPad()
            {
                if let svc = baseViewController.splitViewController
                {
                    svc.showDetailViewController(baseViewController.GetEmptyViewForDetailView(), sender: self)
                }
            }
        }
        return .none
    }
    
}
