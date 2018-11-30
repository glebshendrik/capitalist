//
//  ApplicationRouter.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import Swinject

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
    
    func initDependencies(with resolver: Resolver) {
        accountCoordinator = resolver.resolve(AccountCoordinatorProtocol.self)!
    }
    
    func start(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        if FirstLaunch().isFirstLaunch {
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
        _ = accountCoordinator.loadCurrentUser()
            .done { _ in
                self.showMainViewController()
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
    }
    
    fileprivate func showUserJoinScreen() {
//        show(.JoinNavigationController)
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
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.highlighted)
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
