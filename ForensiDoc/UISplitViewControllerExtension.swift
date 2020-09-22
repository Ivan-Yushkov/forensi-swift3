//
//  UISplitViewControllerExtension.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 19/01/2016.
//  Copyright © 2016 Bitmelter Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UISplitViewController {
    func getCurrentDetailViewController() -> UIViewController {
        let detailNavigationController = self.viewControllers[1];
        return detailNavigationController
    }
    
    func movePopoverButtonFrom(_ currentDetailViewController:UIViewController, newDetailViewController: UIViewController) {
        if let popoverButton = currentDetailViewController.navigationItem.leftBarButtonItem {
            currentDetailViewController.navigationItem.leftBarButtonItem = nil;
            newDetailViewController.navigationItem.leftBarButtonItem = popoverButton;
        }
    }
    
    /*
    - (void) copyMasterPopoverControllerFrom: (UIViewController *) currentDetailViewController to: (UIViewController *) newDetailViewController
    {
    if ([currentDetailViewController isKindOfClass:[BaseDetailViewController class]]
    && [newDetailViewController isKindOfClass:[BaseDetailViewController class]])
    {
    UIPopoverController *masterPopoverController = ((BaseDetailViewController *) currentDetailViewController).masterPopoverController;
    ((BaseDetailViewController *)newDetailViewController).masterPopoverController = masterPopoverController;
    }
    
    }
*/
    
}
