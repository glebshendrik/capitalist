//
//  ApplicationRouterProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import Swinject

protocol ApplicationRouterDependantProtocol {
    var router: ApplicationRouterProtocol! { get set }
}

protocol ApplicationRouterProtocol {
    func start(launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    func application(_ app: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    func route()
    func viewController(_ type: Infrastructure.ViewController) -> UIViewController
    func initDependencies(with resolver: Resolver)
    func setWindow(blurred: Bool)
    func showPasscodeScreen()
    func dismissPresentedAlerts()
    func postDataUpdated()
}
