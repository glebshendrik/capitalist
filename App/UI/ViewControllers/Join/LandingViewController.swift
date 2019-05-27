//
//  LandingViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class LandingViewController : UIViewController {
    
    @IBOutlet weak var loadingMessageLabel: UILabel!
    @IBOutlet weak var loaderImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loaderImageView.showCoinLoader()
    }
    
    func update(loadingMessage: String) {
        loadingMessageLabel.text = loadingMessage
    }
}
