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

class ApplicationRouter : NSObject, ApplicationRouterProtocol {
    
    private let storyboards: [Infrastructure.Storyboard: UIStoryboard]
    private let window: UIWindow
    private let userSessionManager: UserSessionManagerProtocol
    private let notificationsCoordinator: NotificationsCoordinatorProtocol
    private var accountCoordinator: AccountCoordinatorProtocol!
    private let soundsManager: SoundsManagerProtocol
    private var saltEdgeCoordinator: BankConnectionsCoordinatorProtocol!
    
    private var launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    
    init(with storyboards: [Infrastructure.Storyboard: UIStoryboard],
         window: UIWindow,
         userSessionManager: UserSessionManagerProtocol,
         notificationsCoordinator: NotificationsCoordinatorProtocol,
         soundsManager: SoundsManagerProtocol) {
        
        self.storyboards = storyboards
        self.window = window
        self.userSessionManager = userSessionManager
        self.notificationsCoordinator = notificationsCoordinator
        self.soundsManager = soundsManager
    }
    
    func initDependencies(with resolver: Swinject.Resolver) {
        accountCoordinator = resolver.resolve(AccountCoordinatorProtocol.self)!
        saltEdgeCoordinator = resolver.resolve(BankConnectionsCoordinatorProtocol.self)!
    }
    
    func start(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        if UIFlowManager.isFirstAppLaunch {
            userSessionManager.forgetSession()            
        }
        if !UIFlowManager.reach(point: .soundsManagerInitialization) {
            soundsManager.setSounds(enabled: true)
        }
        saltEdgeCoordinator.setup()
        self.launchOptions = launchOptions
        setupKeyboardManager()
        setupAppearance()
        setupLocale()
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
        
        showLandingScreen()
        
        beginAuthorizedUserFlow()
    }
    
    private func beginAuthorizedUserFlow() {
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
    
    private func errorIsNotFoundOrNotAuthorized(error: Error) -> Bool {
        switch error {
        case APIRequestError.notAuthorized,
             APIRequestError.notFound:
            return true
        default:
            return false
        }
    }
    
    private func showLandingScreen() {
        _ = show(.LandingViewController)
    }
    
    private func showJoiningAsGuestScreen() {
        if let landingViewController = show(.LandingViewController) as? LandingViewController {
            landingViewController.update(loadingMessage: "Создание учетной записи гостя...")
        }
    }
    
    func showMainViewController() {
        _ = show(.MainViewController)
        if let menuLeftNavigationController = viewController(.MenuNavigationController) as? UISideMenuNavigationController {
            SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        }
        notificationsCoordinator.enableNotifications()
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
                
        UINavigationBar.appearance().barTintColor = UIColor.by(.dark333D5B)
    }
    
    private func setupKeyboardManager() {
        let keyboardManager = IQKeyboardManager.shared()
        keyboardManager.isEnabled = true
        keyboardManager.shouldResignOnTouchOutside = true
        keyboardManager.shouldShowToolbarPlaceholder = false
        keyboardManager.toolbarDoneBarButtonItemText = ""
        keyboardManager.toolbarDoneBarButtonItemImage = UIImage(named: "close-icon")?.withRenderingMode(.alwaysTemplate)
        keyboardManager.isEnableAutoToolbar = false
    }
    
    private func setupLocale() {
        InternationalControl.shared.language = .russian
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, sourceApplication: String?) -> Bool {
        return true
    }    
}
