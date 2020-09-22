//
//  AppDelegate.swift
//  ForensiDoc

import UIKit

//TODO:Bug 1.Delete app, 2. Press setup pascode, 3. Don't do anything, 4. Kill the app. 5.You will be logged on

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    @IBOutlet var window: UIWindow?
    var splitController: UISplitViewController?
    var navigationControllerDelegate: NavigationControllerDelegate?
    var splitViewControllerDelegate = SplitViewControllerDelegate()
    var backgroundTransferCompletionHandler: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        BitmelterAccountManager.startSharedInstance(BitmelterAccountManagerDelegate())
        let bitmelterAccountManager = BitmelterAccountManager.sharedInstance
        bitmelterAccountManager.onSuccessfullLogon { () -> Void in
            self.switchToMainNavigationController(true)
        }
        bitmelterAccountManager.onSuccessfullPasscode { () -> Void in
            self.switchToMainNavigationController(true)
        }
        bitmelterAccountManager.onSuccessfullAccountActivation { () -> Void in
            self.switchToMainNavigationController(true)
        }
        
        let user = DataManager.sharedInstance.user()
        
        var rootController: (viewController: BaseViewController, showAsSplitView: Bool)
        
        if user.isUsingPasscode() || user.isLoggedOn()
        {
            rootController = self.getMainNavigationViewController(false)
        }
        else
        {
            rootController = self.getWelcomeViewNavigationController(false)
        }
        
        if rootController.showAsSplitView
        {
            splitController = self.getSplitViewController(rootController.viewController)
            self.window?.rootViewController = splitController
        }
        else
        {
            self.window?.rootViewController = UINavigationController(rootViewController: rootController.viewController)
        }
               
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        self.backgroundTransferCompletionHandler = completionHandler
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if !DataManager.sharedInstance.handleOpenUrl(url) {
            //url was not related to password reset or account activation
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        (splitController?.navigationController?.visibleViewController as? BaseViewController)?.setStartedFromBackground()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        (splitController?.navigationController?.visibleViewController as? BaseViewController)?.didBecomeActive()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if ViewsHelpers.IsiPad() {
            return UIInterfaceOrientationMask.all
        }
        return UIInterfaceOrientationMask.portrait
    }
    
    func switchToMainNavigationController(_ isSwitching: Bool) {
        DispatchQueue.main.async(execute: {
            let mainNavController = self.getMainNavigationViewController(isSwitching)
            var rootController: UIViewController?
            if mainNavController.showAsSplitView {
                self.splitController = self.getSplitViewController(mainNavController.viewController)
                rootController = self.splitController
            } else {
                rootController = UINavigationController(rootViewController: mainNavController.viewController)
            }
            self.setupRootViewController(rootController, animated: true, transition: UIViewAnimationOptions.transitionFlipFromLeft)
        })
    }
    
    func switchToWelcomeNavigationController(_ isSwitching: Bool) {
        DispatchQueue.main.async(execute: {
            let welcomeNavController = self.getWelcomeViewNavigationController(isSwitching)
            var rootController: UIViewController?
            if welcomeNavController.showAsSplitView {
                self.splitController = self.getSplitViewController(welcomeNavController.viewController)
                rootController = self.splitController
            } else {
                rootController = UINavigationController(rootViewController: welcomeNavController.viewController)
            }
            
            self.setupRootViewController(rootController, animated: true, transition: UIViewAnimationOptions.transitionFlipFromRight)
        })
    }
    
    func getMainNavigationViewController(_ isSwitching: Bool) -> (viewController: BaseViewController, showAsSplitView: Bool) {
        //At this stage we already know that user must have logged on at least once
        let user = DataManager.sharedInstance.user()
        var baseViewController: BaseViewController
        var showAsSplitView = false
        
        if user.isUsingPasscode() && !isSwitching {
            baseViewController = PasscodeViewController.GetPasscodeViewController()
        } else {
            if user.isLoggedOn() {
                showAsSplitView = true
                let repo = ForensiDocEntryFormRepository()
                let entryForms = repo.LoadJSONFormSpecs()
                if entryForms.count == 1 {
                    let entryFormDetails: EntryFormDetailsViewController = EntryFormDetailsViewController(nibName:"EntryFormDetailsView", bundle:nil)
                    entryFormDetails.entryForm = EntryForm(jsonSpec: entryForms[0], doNotCheckForHiddenFields: true)
                    entryFormDetails.isMainView = true
                    baseViewController = entryFormDetails
                } else {
                    baseViewController = MainViewController(nibName:"MainView", bundle:nil)
                }
            } else {
                showAsSplitView = false
                baseViewController = WelcomeViewController(nibName:"WelcomeView", bundle:nil)
                if DataManager.sharedInstance.helperData().hasResetPasswordCode() {
                    let passwordResetViewController: PasswordResetViewController? = nil
                    baseViewController.navigateToView(passwordResetViewController)
                } else if user.isRegisteredAndActivated() {
                    let loginViewController: LoginViewController? = nil
                    baseViewController.navigateToView(loginViewController)
                }
            }
        }
        
        return (baseViewController, showAsSplitView)
    }
    
    func getWelcomeViewNavigationController(_ isSwitching: Bool) -> (viewController: BaseViewController, showAsSplitView: Bool){
        let user = DataManager.sharedInstance.user()
        
        let baseViewController = WelcomeViewController(nibName:"WelcomeView", bundle:nil)
        
        if user.isRegisteredButNotActivated() {
            let activateNewAccount: ActivateAccountViewController? = nil
            baseViewController.navigateToView(activateNewAccount)
        } else if user.isRegisteredAndActivated() {
            if user.hasCreatedPasscode() {
                //Go straight to logon screen
                if DataManager.sharedInstance.helperData().hasResetPasswordCode() {
                    let passwordResetViewController: PasswordResetViewController? = nil
                    baseViewController.navigateToView(passwordResetViewController)
                } else {
                    let loginViewController: LoginViewController? = nil
                    baseViewController.navigateToView(loginViewController)
                }
            } else {
                //Create passcode first
                let createPasscodeViewController: CreatePasscodeViewController? = nil
                baseViewController.navigateToView(createPasscodeViewController)
            }
        }
        
        return (baseViewController, false)
    }
    
    func getSplitViewController(_ viewController: UIViewController) -> UISplitViewController {
        let emptyDetail: EmptyDetailViewController = EmptyDetailViewController(nibName:"EmptyDetailView", bundle:nil)
        
        let masterViewController = UINavigationController(rootViewController: viewController)
        if ViewsHelpers.IsiPad() {
            if let navDelegate = self.navigationControllerDelegate {
                masterViewController.delegate = navDelegate
            } else {
                self.navigationControllerDelegate = NavigationControllerDelegate()
                masterViewController.delegate = self.navigationControllerDelegate!
            }
        }
        
        let splitController = UISplitViewController()
        splitController.delegate = splitViewControllerDelegate
        splitController.viewControllers = [masterViewController,UINavigationController(rootViewController: emptyDetail)]
        self.splitController = splitController
        return splitController
    }
    
    func setupRootViewController(_ newRootViewController: UIViewController?, animated: Bool, transition: UIViewAnimationOptions) {
        if let window = self.window, let rootVC = newRootViewController {
            
            window.rootViewController = rootVC
            
            // The animation below is causing that fucking bug with the border!
            /*
            if animated {
                UIView.transitionWithView(window, duration: 0.5, options: transition, animations: { () -> Void in
                    window.rootViewController = rootVC
                    }, completion: nil)
            } else {
                window.rootViewController = rootVC
            }
            */
        }
    }
}

