//
//  AppDelegate.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
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
        return router.application(application, open: url, sourceApplication: sourceApplication)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        _ = notificationsCoordinator.register(deviceToken: deviceToken)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        notificationsCoordinator.cancelKeepAliveNotifications()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        notificationsCoordinator.rescheduleKeepAliveNotifications()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        notificationsCoordinator.updateBadges()
    }
    
    @objc(application:didReceiveLocalNotification:) func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        // Receive local notification when app is active or in background and click on notification.
        notificationsCoordinator.application(application, didReceive: notification, in: application.applicationState)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        notificationsCoordinator.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler, applicationStateWhenReceivedNotification: application.applicationState)
    }
    
    @objc(application:handleActionWithIdentifier:forLocalNotification:completionHandler:) func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        // Received when in background or foreground and clicked on action with `identifier`
        notificationsCoordinator.application(application, handleActionWithIdentifier: identifier, forLocalNotification: notification, completionHandler: completionHandler, applicationStateWhenReceivedNotification: application.applicationState)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        notificationsCoordinator.application(application, handleActionWithIdentifier: identifier, forRemoteNotification: userInfo, completionHandler: completionHandler, applicationStateWhenReceivedNotification: application.applicationState)
    }


}

