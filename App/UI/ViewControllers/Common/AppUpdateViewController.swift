//
//  AppUpdateViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 15.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class AppUpdateViewController : UIViewController {    
    @IBAction func didTapUpdateButton(_ sender: Any) {
        gotoApp(appID: "123")
    }
    
    private func gotoApp(appID: String, completion: ((_ success: Bool)->())? = nil) {
        let appUrl = "itms-apps://itunes.apple.com/app/id\(appID)"

        gotoURL(string: appUrl, completion: completion)
    }
    
    private func gotoURL(string: String, completion: ((_ success: Bool)->())? = nil) {
        print("gotoURL: ", string)
        guard let url = URL(string: string) else {
            print("gotoURL: invalid url", string)
            completion?(false)
            return
        }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: completion)
        } else {
            completion?(UIApplication.shared.openURL(url))
        }
    }
}
