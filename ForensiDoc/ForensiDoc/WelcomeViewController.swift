//
//  WelcomeViewController.swift
//  ForensiDoc
//
//  Created by Andrzej Czarkowski on 18/11/2014.
//  Copyright (c) 2014 Bitmelter Ltd. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseViewController {
    @IBOutlet var activateAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let svc = self.splitViewController {
            svc.preferredDisplayMode = .primaryHidden
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user = DataManager.sharedInstance.user()
        let d = !user.isLoggedOn() && user.isRegisteredButNotActivated()
        self.activateAccountButton?.alpha = d ? 1.0 : 0.0
    }
    
    @IBAction func createNewAccount(_ sender: AnyObject){
        let registerForNewAccount:RegisterForNewAccountViewController? = nil;
        self.navigateToView(registerForNewAccount)
    }
    @IBAction func privacyPolicyTapped(_ sender: AnyObject) {
        let privacyPolicyViewController: PrivacyPolicyViewController? = nil
        self.navigateToView(privacyPolicyViewController)
    }
    
    @IBAction func loginWithExistingAccount(_ sender: AnyObject){
        let user = DataManager.sharedInstance.user()
        if user.hasCreatedPasscode() {
            //Go straight to logon screen
            let loginViewController: LoginViewController? = nil
            self.navigateToView(loginViewController)
        } else {
            //Create passcode first
            let createPasscodeViewController: CreatePasscodeViewController? = nil
            self.navigateToView(createPasscodeViewController)
        }
    }
    
    @IBAction func loginAsGuest(_ sender: AnyObject){
        let user = DataManager.sharedInstance.user()
        user.localUserOnly = true
        if user.hasCreatedPasscode() {
            //Go straight to main view
            BitmelterAccountManager.sharedInstance.triggerSuccessFullLogon()
        } else {
            //Create passcode first
            let createPasscodeViewController: CreatePasscodeViewController? = nil
            self.navigateToView(createPasscodeViewController)
        }
    }
    
    @IBAction func activateAccountButtonTapped(_ sender: AnyObject) {
        let activateAccountView:ActivateAccountViewController? = nil
        self.navigateToView(activateAccountView)
    }
}
