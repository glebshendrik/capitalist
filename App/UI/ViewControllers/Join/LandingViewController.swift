//
//  LandingViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import Lottie

class LandingViewController : UIViewController {
    
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var loadingMessageLabel: UILabel?
    
    var loadingMessage: String? = nil {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let starAnimation = Animation.named("start-animation")
        animationView.animation = starAnimation
        animationView.play(fromProgress: 1, toProgress: 1, loopMode: .playOnce, completion: nil)
        updateUI()
    }
        
    private func updateUI() {
        
        loadingMessageLabel?.text = loadingMessage
    }
}
