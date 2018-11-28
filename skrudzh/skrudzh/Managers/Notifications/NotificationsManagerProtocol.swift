//
//  NotificationsManagerProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol NotificationsManagerProtocol {
    var systemNotificationsEnabled: Promise<Bool> { get }
    
    func enableNotifications() -> Promise<Void>
    func disableNotifications() -> Promise<Void>
    func rescheduleKeepAliveNotifications()
    func cancelKeepAliveNotifications()
    func cancelAllSceduledNotifications()
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification, in state: UIApplication.State)
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: @escaping () -> Void, applicationStateWhenReceivedNotification state: UIApplication.State)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void, applicationStateWhenReceivedNotification state: UIApplication.State)
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void, applicationStateWhenReceivedNotification state: UIApplication.State)
}
