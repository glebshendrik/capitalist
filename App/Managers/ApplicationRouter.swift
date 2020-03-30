//
//  ApplicationRouter.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import Swinject
import SideMenu
import PromiseKit
import IQKeyboardManager
import RecurrencePicker
import SwifterSwift
import SwiftyGif
import ApphudSDK
import Firebase
import FirebaseCoreDiagnostics
import FBSDKCoreKit

class ApplicationRouter : NSObject, ApplicationRouterProtocol {
    private let storyboards: [Infrastructure.Storyboard: UIStoryboard]
    private let window: UIWindow
    private let userSessionManager: UserSessionManagerProtocol
    private let notificationsCoordinator: NotificationsCoordinatorProtocol
    private var accountCoordinator: AccountCoordinatorProtocol!
    private let soundsManager: SoundsManagerProtocol
    private var saltEdgeCoordinator: BankConnectionsCoordinatorProtocol!
    private let analyticsManager: AnalyticsManagerProtocol
    private var biometricVerificationManager: BiometricVerificationManagerProtocol
    
    private var launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    private var minVersion: String?
    private var minBuild: String?
    
    init(with storyboards: [Infrastructure.Storyboard: UIStoryboard],
         window: UIWindow,
         userSessionManager: UserSessionManagerProtocol,
         notificationsCoordinator: NotificationsCoordinatorProtocol,
         soundsManager: SoundsManagerProtocol,
         analyticsManager: AnalyticsManagerProtocol,
         biometricVerificationManager: BiometricVerificationManagerProtocol) {
        
        self.storyboards = storyboards
        self.window = window
        self.userSessionManager = userSessionManager
        self.notificationsCoordinator = notificationsCoordinator
        self.soundsManager = soundsManager
        self.analyticsManager = analyticsManager
        self.biometricVerificationManager = biometricVerificationManager
    }
        
    func initDependencies(with resolver: Swinject.Resolver) {
        accountCoordinator = resolver.resolve(AccountCoordinatorProtocol.self)!
        saltEdgeCoordinator = resolver.resolve(BankConnectionsCoordinatorProtocol.self)!
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        return handled
    }
    
    func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func start(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.launchOptions = launchOptions
        handleFirstAppLaunch()
        setupServices()
        setupFacebook(launchOptions)
        launch()
    }
    
    func launch() {
        guard let startAnimationViewController = show(.StartAnimationViewController) as? StartAnimationViewController else {
            route()
            return
        }
        do {
            try startAnimationViewController.startAnimationWith(delegate: self)
        }
        catch {
            route()
        }
    }
    
    func route() {
        guard userSessionManager.isUserAuthenticated else {
            showJoiningAsGuestScreen()
            _ = accountCoordinator.joinAsGuest().catch { _ in
                self.route()
            }
            return
        }
        
        if isAppUpdateNeeded() {
            showAppUpdateScreen()
            return
        }
        
        showLandingScreen()
        
        authorizedRoute()
    }
    
    private func authorizedRoute() {
        firstly {
            accountCoordinator.loadCurrentUser()
        }.done { user in
            
            if self.isAppUpdateNeeded() {
                self.showAppUpdateScreen()
                return
            }
            
            guard UIFlowManager.reached(point: .onboarding) || user.onboarded else {
                self.showOnboardingViewController()
                return
            }
            
            self.notificationsCoordinator.enableNotifications()
            
            guard UIFlowManager.reached(point: .dataSetup) || user.onboarded else {
                self.showDataSetupViewController()
                return
            }
            
            guard UIFlowManager.reached(point: .subscription) || self.accountCoordinator.currentUserHasActiveSubscription else {
                self.showSubscriptionScreen()
                return
            }
            
            self.showMainViewController()
        }.catch { error in
            if self.errorIsNotFoundOrNotAuthorized(error: error) {
                self.userSessionManager.forgetSession()
            }
            self.route()
        }
    }
    
    private func errorIsNotFoundOrNotAuthorized(error: Error) -> Bool {
        switch error {
        case APIRequestError.notAuthorized,
             APIRequestError.notFound:
            return true
        default:
            return false
        }
    }
}

extension ApplicationRouter {
    private func setupServices() {
        setupSoundsManager()
        setupKeyboardManager()
        setupAppearance()
        setupBiometric()
        setupSaltEdge()
        setupApphud()
        setupAnalytics()
    }
    
    func setupAppearance() {
        let backArrowImage = UIImage(named: "back-button-icon")
        let renderedImage = backArrowImage?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = renderedImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = renderedImage
        
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 18)!,
                          NSAttributedString.Key.foregroundColor : UIColor.by(.white100)]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: UIControl.State.highlighted)
        
        UINavigationBar.appearance().barTintColor = UIColor.by(.black2)
        
        UITextField.appearance().tintColor = UIColor.by(.white64)
        
    }
    
    private func setupKeyboardManager() {
        let keyboardManager = IQKeyboardManager.shared()
        keyboardManager.isEnabled = true
        keyboardManager.shouldResignOnTouchOutside = true
        keyboardManager.shouldShowToolbarPlaceholder = false
        keyboardManager.toolbarDoneBarButtonItemText = ""
        keyboardManager.keyboardAppearance = .alert
        keyboardManager.overrideKeyboardAppearance = true
        keyboardManager.toolbarDoneBarButtonItemImage = UIImage(named: "close-icon")?.withRenderingMode(.alwaysTemplate)
        keyboardManager.isEnableAutoToolbar = false
    }
    
    private func setupApphud() {
        Apphud.start(apiKey: "app_mHJ17n3JPJiohGj5JgwNkkermyShF1")
        Apphud.setDelegate(self)
    }
    
    private func setupSaltEdge() {
        saltEdgeCoordinator.setup()
    }
    
    private func setupAnalytics() {
        analyticsManager.setup()        
    }
    
    private func setupSoundsManager() {
        if !UIFlowManager.reach(point: .soundsManagerInitialization) {
            soundsManager.setSounds(enabled: false)
        }
    }
    
    private func setupBiometric() {
        biometricVerificationManager.allowableReuseDuration = 180
        if !UIFlowManager.reach(point: .verificationManagerInitialization) {            
            biometricVerificationManager.setInAppBiometricVerification(enabled: true)
        }        
    }
    
    private func handleFirstAppLaunch() {
        if UIFlowManager.isFirstAppLaunch {
            userSessionManager.forgetSession()
        }
    }
    
    private func setupFacebook(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        Settings.isAutoInitEnabled = true
        ApplicationDelegate.initializeSDK(nil)
        ApplicationDelegate.shared.application(UIApplication.shared, didFinishLaunchingWithOptions: launchOptions)
        AppLinkUtility.fetchDeferredAppLink { (url, error) in
            if let error = error {
                print("Received error while fetching deferred app link %@", error)
            }
            if let url = url {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }    
}

extension ApplicationRouter {
    private func showAppUpdateScreen() {
        _ = show(.AppUpdateViewController)
    }
    
    private func showLandingScreen() {
        _ = show(.LandingViewController)
    }
    
    private func showSubscriptionScreen() {
        window.rootViewController = UINavigationController(rootViewController: self.viewController(.SubscriptionViewController))
    }
    
    private func showJoiningAsGuestScreen() {
        if let landingViewController = show(.LandingViewController) as? LandingViewController {
            landingViewController.update(loadingMessage: NSLocalizedString("Creating guest account", comment: "Создание учетной записи гостя..."))
        }
    }
    
    func showMainViewController() {
        _ = show(.MainViewController)
        showPasscodeScreen()
        if let menuLeftNavigationController = viewController(.MenuNavigationController) as? SideMenuNavigationController {
            SideMenuManager.default.leftMenuNavigationController = menuLeftNavigationController
        }
    }
    
    func showPasscodeScreen() {
        if biometricVerificationManager.shouldVerify {
            modal(.PasscodeViewController)
        }
    }
    
    func showOnboardingViewController() {
        _ = show(.OnboardingViewController)
    }
    
    func showDataSetupViewController() {
        _ = show(.TransactionablesCreationViewController)
    }
        
    func show(_ viewController: Infrastructure.ViewController) -> UIViewController? {
        window.rootViewController = self.viewController(viewController)
        return window.rootViewController
    }
    
    func modal(_ viewController: Infrastructure.ViewController) {    window.rootViewController?.topmostPresentedViewController.modal(self.viewController(viewController))
    }
    
    func setWindow(blurred: Bool) {
        let blurViewTagId = 999
        blurred ? window.addBlur(with: blurViewTagId) : window.removeBlur(with: blurViewTagId)
    }
    
    func viewController(_ viewController: Infrastructure.ViewController) -> UIViewController {
        let storyboard = self.storyboards[viewController.storyboard]
        return storyboard!.instantiateViewController(withIdentifier: viewController.identifier)
    }
}

extension ApplicationRouter {
    func setMinimumAllowed(version: String?, build: String?) {
        minVersion = version
        minBuild = build
        if isAppUpdateNeeded() {
            route()
        }
    }
    
    private func isAppUpdateNeeded() -> Bool {
        guard   let minBuild = minBuild,
                let appBuild = UIApplication.shared.buildNumber,
                let minBuildNumber = Int(minBuild),
                let appBuildNumber = Int(appBuild) else {
            return false
        }
        return appBuildNumber < minBuildNumber
    }
}

extension ApplicationRouter : ApphudDelegate {
    func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription]) {
        _ = accountCoordinator.updateUserSubscription()
    }
}

extension ApplicationRouter : SwiftyGifDelegate {
    func gifURLDidFinish(sender: UIImageView) {
        print("gifURLDidFinish")
    }

    func gifURLDidFail(sender: UIImageView) {
        print("gifURLDidFail")
    }

    func gifDidStart(sender: UIImageView) {
        print("gifDidStart")
    }
    
    func gifDidLoop(sender: UIImageView) {
        print("gifDidLoop")
    }
    
    func gifDidStop(sender: UIImageView) {
        route()
    }
}
