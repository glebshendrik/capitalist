//
//  StartAnimationViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 03.03.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import Lottie

protocol StartAnimationViewControllerDelegate : class {
    func animationDidStop()
}

class StartAnimationViewController : UIViewController {
    
    @IBOutlet weak var animationView: AnimationView!
    weak var delegate: StartAnimationViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let starAnimation = Animation.named("start-animation")
        animationView.animation = starAnimation
        animationView.animationSpeed = 3
        
        animationView.play { (finished) in
            self.delegate?.animationDidStop()
        }
    }
}
