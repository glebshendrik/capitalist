//
//  LandingViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class LandingViewController : UIViewController {
    
    @IBOutlet weak var loadingMessageLabel: UILabel?
    @IBOutlet weak var loaderImageView: UIImageView!
    
    var loadingMessage: String? = nil {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        loadingMessageLabel?.text = loadingMessage
    }
}
