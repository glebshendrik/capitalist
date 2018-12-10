//
//  ApplicationRouter.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import Swinject
import SideMenu
import PromiseKit

class ApplicationRouter : NSObject, ApplicationRouterProtocol {
    
    private let storyboards: [Infrastructure.Storyboard: UIStoryboard]
    private let window: UIWindow
    private let userSessionManager: UserSessionManagerProtocol
    private let notificationsCoordinator: NotificationsCoordinatorProtocol
    private var accountCoordinator: AccountCoordinatorProtocol!
    
    private var launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    
    init(with storyboards: [Infrastructure.Storyboard: UIStoryboard],
         window: UIWindow,
         userSessionManager: UserSessionManagerProtocol,
         notificationsCoordinator: NotificationsCoordinatorProtocol) {
        
        self.storyboards = storyboards
        self.window = window
        self.userSessionManager = userSessionManager
        self.notificationsCoordinator = notificationsCoordinator
    }
    
    func initDependencies(with resolver: Swinject.Resolver) {
        accountCoordinator = resolver.resolve(AccountCoordinatorProtocol.self)!
    }
    
    func start(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        if UIFlowManager.isFirstAppLaunch {
            userSessionManager.forgetSession()
        }
        self.launchOptions = launchOptions
        setupAppearance()
        route()
    }
    
    func route() {
        guard userSessionManager.isUserAuthenticated else {
            // If the user is not authenticated ask for login
            showJoiningAsGuestScreen()
            _ = accountCoordinator.joinAsGuest().catch { _ in
                self.route()
            }
            return
        }
        
        // Show the extended splash screen (or landing page)
        showLandingScreen()
        
        // Begin authorized user experience flow
        beginAuthorizedUserFlow()
    }
    
    fileprivate func beginAuthorizedUserFlow() {
        firstly {
            accountCoordinator.loadCurrentUser()
        }.done { _ in
            if UIFlowManager.wasShownOnboarding {
                self.showMainViewController()
            }
            else {
                self.showOnboardingViewController()
            }
            
        }.catch { error in
            if self.errorIsNotFoundOrNotAuthorized(error: error) {
                self.userSessionManager.forgetSession()
            }
            self.route()
        }
    }
    
    fileprivate func errorIsNotFoundOrNotAuthorized(error: Error) -> Bool {
        switch error {
        case APIRequestError.notAuthorized,
             APIRequestError.notFound:
            return true
        default:
            return false
        }
    }
    
    fileprivate func showLandingScreen() {
        _ = show(.LandingViewController)
    }
    
    fileprivate func showJoiningAsGuestScreen() {
        if let landingViewController = show(.LandingViewController) as? LandingViewController {
            landingViewController.update(loadingMessage: "Создание учетной записи гостя...")
        }
    }
    
    func showMainViewController() {
        _ = show(.MainViewController)
        if let menuLeftNavigationController = viewController(.MenuNavigationController) as? UISideMenuNavigationController {
            SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        }        
    }
    
    func showOnboardingViewController() {
        _ = show(.OnboardingViewController)
    }
        
    func show(_ viewController: Infrastructure.ViewController) -> UIViewController? {
        window.rootViewController = self.viewController(viewController)
        return window.rootViewController
    }
    
    func viewController(_ viewController: Infrastructure.ViewController) -> UIViewController {
        let storyboard = self.storyboards[viewController.storyboard]
        assert(storyboard != nil, "Storyboard should be registered before first use.")
        return storyboard!.instantiateViewController(withIdentifier: viewController.identifier)
    }
    
    func setupAppearance() {
        let backArrowImage = UIImage(named: "back-button-icon")
        let renderedImage = backArrowImage?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = renderedImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = renderedImage
        
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.init(red: 0.42,
                                                                                green: 0.58,
                                                                                blue: 0.98,
                                                                                alpha: 1)]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: UIControl.State.highlighted)
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 242 / 255.0,
                                                            green: 245 / 255.0,
                                                            blue: 254 / 255.0,
                                                            alpha: 1.0)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, sourceApplication: String?) -> Bool {
        return true
    }
    
    fileprivate func handleNotificationFromLaunch() {
        guard let launchOptions = launchOptions else { return }
        
        if let remoteNotificationPayload = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            notificationsCoordinator.application(UIApplication.shared,
                                                 didReceiveRemoteNotification: remoteNotificationPayload,
                                                 fetchCompletionHandler: { _ in },
                                                 applicationStateWhenReceivedNotification: .background)
        }
        else if let localNotification = launchOptions[UIApplication.LaunchOptionsKey.localNotification] as? UILocalNotification {
            notificationsCoordinator.application(UIApplication.shared, didReceive: localNotification, in: .background)
        }
        
        self.launchOptions = nil
    }
}
