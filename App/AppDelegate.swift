//
//  AppDelegate.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import SwinjectStoryboard
import Swinject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let assembler = Assembler(container: SwinjectStoryboard.defaultContainer)
    
    var window: UIWindow?
    var router: ApplicationRouterProtocol!
    var notificationsCoordinator: NotificationsCoordinatorProtocol!
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        assembler.apply(assemblies:
            [
                ApplicationAssembly(),
                ManagersAssembly(),
                ServicesAssembly(),
                CoordinatorsAssembly()
            ]
        )
        
        ApplicationAssembly.resolveAppDelegateDependencies(appDelegate: self)
        router.start(launchOptions: launchOptions)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return router.application(app, open: url, options: options)
    }
    
    func application(
        _ application: UIApplication,
        open url: URL,
        sourceApplication: String?,
        annotation: Any
        ) -> Bool {        
        return router.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        _ = notificationsCoordinator.register(deviceToken: deviceToken)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        notificationsCoordinator.cancelKeepAliveNotifications()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        notificationsCoordinator.rescheduleKeepAliveNotifications()
        router.setWindow(blurred: true)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        notificationsCoordinator.updateBadges()
        router.showPasscodeScreen()
        router.setWindow(blurred: false)
    }
}
