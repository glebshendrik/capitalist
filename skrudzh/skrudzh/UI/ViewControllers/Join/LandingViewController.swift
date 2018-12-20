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
    @IBOutlet weak var loaderImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loaderImageView.animationImages = [Int](1...15).compactMap { UIImage(named: "coin-loader-\($0)") }
        loaderImageView.animationDuration = 1
        loaderImageView.startAnimating()
    }
    
    func update(loadingMessage: String) {
        loadingMessageLabel.text = loadingMessage
    }
}
