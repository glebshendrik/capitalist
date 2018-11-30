//
//  LandingViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit

class LandingViewController : UIViewController {
    
    @IBOutlet weak var loadingMessageLabel: UILabel!
    
    func update(loadingMessage: String) {
        loadingMessageLabel.text = loadingMessage
    }
}
