//
//  NotificationsHandlerProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

protocol NotificationsHandlerProtocol {
    
    func handleNotification(category: NotificationCategory?,
                            action: NotificationAction?,
                            applicationStateWhenReceivedNotification state: UIApplication.State)
    
}
