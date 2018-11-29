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
    private let usersService: UsersServiceProtocol
    private let notificationsCoordinator: NotificationsCoordinatorProtocol
    private var accountCoordinator: AccountCoordinatorProtocol!
    
    private var launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    
    init(with storyboards: [Infrastructure.Storyboard: UIStoryboard],
         window: UIWindow,
         userSessionManager: UserSessionManagerProtocol,
         usersService: UsersServiceProtocol,
         notificationsCoordinator: NotificationsCoordinatorProtocol) {
        
        self.storyboards = storyboards
        self.window = window
        self.userSessionManager = userSessionManager
        self.usersService = usersService
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
        route()
    }
    
    func route() {
        // Show the extended splash screen (or landing page)
        showLandingScreen()
        
        guard userSessionManager.isUserAuthenticated else {
            // If the user is not authenticated ask for login
            showUserJoinScreen()
            return
        }
        // Begin authorized user experience flow
        beginAuthorizedUserFlow()
    }
    
    fileprivate func beginAuthorizedUserFlow() {
        _ = usersService.loadUser(with: userSessionManager.currentSession!.userId)
            .done { _ in 
                self.showMainViewController()
            }.catch { _ in
                self.showUserJoinScreen()
        }
    }
    
    fileprivate func showLandingScreen() {
//        show(.LandingViewController)
    }
    
    func showMainViewController() {
//        show(.MainTabBarController)
        notificationsCoordinator.updateBadges()
        //        _ = notificationsCoordinator.enableNotifications()
        handleNotificationFromLaunch()
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
    
    fileprivate func showUserJoinScreen() {
//        show(.JoinNavigationController)
    }
    
    func show(_ viewController: Infrastructure.ViewController) {
        window.rootViewController = self.viewController(viewController)
    }
    
    func viewController(_ viewController: Infrastructure.ViewController) -> UIViewController {
        let storyboard = self.storyboards[viewController.storyboard]
        assert(storyboard != nil, "Storyboard should be registered before first use.")
        return storyboard!.instantiateViewController(withIdentifier: viewController.identifier)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, sourceApplication: String?) -> Bool {
        return true
    }
}
