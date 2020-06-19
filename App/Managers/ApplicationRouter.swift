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
import FirebaseDynamicLinks
import MyTrackerSDK
import SwiftyBeaver
import Adjust

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
    private var userPreferencesManager: UserPreferencesManagerProtocol
    
    private var launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    private var minVersion: String?
    private var minBuild: String?
    private var isAnimating: Bool = false
    private var pendingScreen: UIViewController? = nil
    private var pendingModalScreen: UIViewController? = nil
    
    init(with storyboards: [Infrastructure.Storyboard: UIStoryboard],
         window: UIWindow,
         userSessionManager: UserSessionManagerProtocol,
         notificationsCoordinator: NotificationsCoordinatorProtocol,
         soundsManager: SoundsManagerProtocol,
         analyticsManager: AnalyticsManagerProtocol,
         biometricVerificationManager: BiometricVerificationManagerProtocol,
         userPreferencesManager: UserPreferencesManagerProtocol) {
        
        self.storyboards = storyboards
        self.window = window
        self.userSessionManager = userSessionManager
        self.notificationsCoordinator = notificationsCoordinator
        self.soundsManager = soundsManager
        self.analyticsManager = analyticsManager
        self.biometricVerificationManager = biometricVerificationManager
        self.userPreferencesManager = userPreferencesManager
    }
        
    func initDependencies(with resolver: Swinject.Resolver) {
        accountCoordinator = resolver.resolve(AccountCoordinatorProtocol.self)!
        saltEdgeCoordinator = resolver.resolve(BankConnectionsCoordinatorProtocol.self)!
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            handleIncomingDynamicLink(dynamicLink)
            return true
        }
        let myTrackerResult = MRMyTracker.handleOpen(url, options: options)
        let fbResult = ApplicationDelegate.shared.application(app, open: url, options: options)
        return myTrackerResult || fbResult
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let adjustResult = continueAdjustUserActivity(userActivity, restorationHandler: restorationHandler)
        let myTrackerResult = continueMyTrackerUserActivity(userActivity, restorationHandler: restorationHandler)
        let firebaseResult = continueFirebaseUserActivity(userActivity, restorationHandler: restorationHandler)
        return adjustResult || myTrackerResult || firebaseResult
    }
    
    private func continueAdjustUserActivity(_ userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard   userActivity.activityType == NSUserActivityTypeBrowsingWeb,
                let url = userActivity.webpageURL else { return false }
        
        Adjust.appWillOpen(url)
        
        return true
    }
    
    private func continueMyTrackerUserActivity(_ userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return MRMyTracker.continue(userActivity) { params -> Void in
            guard let restorationHandlerParams = params as? [UIUserActivityRestoring]? else { return }
            restorationHandler(restorationHandlerParams)
        }
    }
    
    private func continueFirebaseUserActivity(_ userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else { return false }
        
        return DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamicLink, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let dynamicLink = dynamicLink {
                self.handleIncomingDynamicLink(dynamicLink)
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let myTrackerResult = MRMyTracker.handleOpen(url, sourceApplication: sourceApplication, annotation: annotation)
        let fbResult = ApplicationDelegate.shared.application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
        Adjust.appWillOpen(url)
        return myTrackerResult || fbResult
    }
    
    func start(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.launchOptions = launchOptions
        handleFirstAppLaunch()
        setupServices()
        setupFacebook(launchOptions)
        launch()
    }
    
    func launch() {
        guard let startAnimationViewController = viewController(.StartAnimationViewController) as? StartAnimationViewController else {
            route()
            return
        }
        show(startAnimationViewController)
        do {
            isAnimating = true
            try startAnimationViewController.startAnimationWith(delegate: self)
        }
        catch {
            isAnimating = false
        }
        route()
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
    
    func postDataUpdated() {
        NotificationCenter.default.post(name: MainViewController.finantialDataInvalidatedNotification, object: nil)
    }
}

extension ApplicationRouter {
    private func setupServices() {
        setupUserPreferences()
        setupSoundsManager()
        setupKeyboardManager()
        setupAppearance()
        setupBiometric()
        setupSaltEdge()
        setupApphud()
        setupMyTracker()
        setupAnalytics()
        setupLogger()
        setupAdjust()
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
    
    private func setupAdjust() {
        let config = ADJConfig(appToken: "uu6gmcz0juo0", environment: ADJEnvironmentProduction)
        config?.delegate = self
        Adjust.appDidLaunch(config)
    }
    
    private func setupSaltEdge() {
        saltEdgeCoordinator.setup()
    }
    
    private func setupAnalytics() {
        analyticsManager.setup()        
    }
    
    func setupUserPreferences() {
        if !UIFlowManager.reach(point: .userPreferencesManagerInitialization) {
            userPreferencesManager.fastGesturePressDurationMilliseconds = 250
        }
    }
    
    private func setupSoundsManager() {
        if !UIFlowManager.reach(point: .soundsManagerInitialization) {
            soundsManager.setSounds(enabled: false)
        }
    }
    
    private func setupBiometric() {
        biometricVerificationManager.allowableReuseDuration = 60
        if !UIFlowManager.reach(point: .verificationManagerInitialization) {            
            biometricVerificationManager.setInAppBiometricVerification(enabled: true)
        }        
    }
    
    private func setupLogger() {
//        let console = ConsoleDestination()
        let cloud = SBPlatformDestination(appID: "9GzNgj", appSecret: "fbu0pHuwbvvaLjDllk14njfkwuflluta", encryptionKey: "ancdIrinQlbaycys7xzmofxwuubo2fg9")
//        SwiftyBeaver.addDestination(console)
        SwiftyBeaver.addDestination(cloud)
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
    
    private func setupMyTracker() {
        MRMyTracker.setAttributionDelegate(self)
    }
    
    private func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        handleIncomingDeeplinkURL(dynamicLink.url)
    }
    
    private func handleIncomingDeeplinkURL(_ url: URL?) {
        guard let url = url else { return }
        analyticsManager.track(event: "deeplink_link", parameters: ["url": url.absoluteString])
        guard   let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let queryItems = components.queryItems else { return }
        for queryItem in queryItems {
            analyticsManager.track(event: queryItem.name, parameters: nil)
            if let value = queryItem.value {
                analyticsManager.track(event: "\(queryItem.name)_\(value)", parameters: nil)
            }
        }
    }
}

extension ApplicationRouter {
    private func showAppUpdateScreen() {
        show(.AppUpdateViewController)
    }
    
    private func showLandingScreen() {
        show(.LandingViewController)
    }
    
    private func showSubscriptionScreen() {
        show(UINavigationController(rootViewController: viewController(.SubscriptionViewController)))
    }
    
    private func showJoiningAsGuestScreen() {
        guard let landingViewController = viewController(.LandingViewController) as? LandingViewController else { return }
        landingViewController.loadingMessage = NSLocalizedString("Creating guest account", comment: "Создание учетной записи гостя...")
        show(landingViewController)
    }
    
    func showMainViewController() {
        show(.MainViewController) {
            self.showPasscodeScreen()
            if let menuLeftNavigationController = self.viewController(.MenuNavigationController) as? SideMenuNavigationController {
                SideMenuManager.default.leftMenuNavigationController = menuLeftNavigationController
            }
        }
    }
    
    func showPasscodeScreen() {
        if biometricVerificationManager.shouldVerify {
            modal(.PasscodeViewController)
        }
    }
    
    private func showOnboardingViewController() {
        show(.OnboardingViewController)
    }
    
    private func showDataSetupViewController() {
        show(.TransactionablesCreationViewController)
    }
        
    private func show(_ viewController: Infrastructure.ViewController, animated: Bool = true, _ completion: (() -> Void)? = nil) {
        show(self.viewController(viewController), animated: animated, completion)
    }
    
    private func show(_ viewController: UIViewController, animated: Bool = true, _ completion: (() -> Void)? = nil) {
        if isAnimating {
            pendingScreen = viewController
            completion?()
        }
        else {
            switchRoot(to: viewController, animated: animated, completion)
        }
    }
    
    private func modal(_ viewController: Infrastructure.ViewController) {
        let screen = self.viewController(viewController)
        if isAnimating {
            pendingModalScreen = screen
        }
        else {
            window.rootViewController?.topmostPresentedViewController.modal(screen, animated: true)
        }
    }
    
    private func showPendings() {
        isAnimating = false
        let pendingScreen = self.pendingScreen
        self.pendingScreen = nil
                
        func showModal() {
            let modal = self.pendingModalScreen
            self.pendingModalScreen = nil
            self.window.rootViewController?.topmostPresentedViewController.modal(modal, animated: true)
        }
        
        guard let screen = pendingScreen else {
            showModal()
            return
        }
        switchRoot(to: screen, animated: true) {
            showModal()
        }
    }
    
    private func switchRoot(to viewController: UIViewController, animated: Bool = true, _ completion: (() -> Void)? = nil) {
        window.switchRootViewController(to: viewController, animated: animated, duration: 0.2, options: .transitionCrossDissolve, completion)
    }
    
    func setWindow(blurred: Bool) {
        let blurViewTagId = 999
        blurred ? window.addBlur(with: blurViewTagId) : window.removeBlur(with: blurViewTagId)
    }
    
    func dismissPresentedAlerts() {
        window.rootViewController?.topmostPresentedViewController.dismissIfAlert()
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

extension ApplicationRouter : MRMyTrackerAttributionDelegate {
    func didReceive(_ attribution: MRMyTrackerAttribution) {
        guard let deeplink = attribution.deeplink, let url = URL(string: deeplink) else { return }
        handleIncomingDeeplinkURL(url)
    }
}

extension ApplicationRouter : ApphudDelegate {
    func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription]) {
        _ = accountCoordinator.updateUserSubscription()
    }
}

extension ApplicationRouter : AdjustDelegate {
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        if let data = attribution?.dictionary() {
            Apphud.addAttribution(data: data, from: .adjust) { (result) in }
        } else if let adid = Adjust.adid() {
            Apphud.addAttribution(data: ["adid" : adid], from: .adjust) { (result) in }
        }
    }
    
    func adjustDeeplinkResponse(_ deeplink: URL?) -> Bool {
        return true
    }
}

extension ApplicationRouter : SwiftyGifDelegate {
    func gifURLDidFinish(sender: UIImageView) {
        print("gifURLDidFinish")
    }

    func gifURLDidFail(sender: UIImageView) {
        print("gifURLDidFail")
//        showPendings()
    }

    func gifDidStart(sender: UIImageView) {
        print("gifDidStart")
    }
    
    func gifDidLoop(sender: UIImageView) {
        print("gifDidLoop")
    }
    
    func gifDidStop(sender: UIImageView) {
        showPendings()
    }
}
