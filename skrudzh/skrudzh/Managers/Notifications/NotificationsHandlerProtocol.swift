//
//  NotificationsHandlerProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit

protocol NotificationsHandlerProtocol {
    
    func handleNotification(category: NotificationCategory?,
                            action: NotificationAction?,
                            title: String?,
                            message: String?,
                            applicationStateWhenReceivedNotification state: UIApplication.State)
    
}
