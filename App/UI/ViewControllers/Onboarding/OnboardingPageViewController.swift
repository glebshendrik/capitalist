//
//  OnboardingPageViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class OnboardingPageGradientViewController : UIViewController {
    @IBOutlet weak var overlay: UIView!
    
    var firstColor: UIColor { return .clear }
    var secondColor: UIColor { return .clear }
    var thirdColor: UIColor { return .clear }
    
    var gradient: CAGradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.transition(with: self.view,
                          duration: 0.25,
                          options: UIView.AnimationOptions.transitionCrossDissolve,
                          animations: { [weak self] () -> Void in
                            guard let weakSelf = self else { return }
                            weakSelf.overlay.layer.addSublayer(weakSelf.gradient)
            }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gradient.removeFromSuperlayer()
    }
    
    func setupGradient() {
        overlay.layer.compositingFilter = "overlayBlendMode"
        gradient.colors = [
            firstColor.cgColor,
            secondColor.cgColor,
            thirdColor.cgColor
        ]
        gradient.locations = [0, 0.31, 1]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradient.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0,
                                                                                b: 1,
                                                                                c: -1,
                                                                                d: 0,
                                                                                tx: 1,
                                                                                ty: 0))
        gradient.bounds = overlay.bounds.insetBy(dx: -0.5 * overlay.bounds.size.width,
                                                 dy: -0.5 * overlay.bounds.size.height)
        gradient.position = overlay.center
    }
}

class OnboardingPage4ViewController : OnboardingPageGradientViewController {
    override var firstColor: UIColor {
        return UIColor(red: 0.31, green: 0.82, blue: 0.63, alpha: 1)
    }
    override var secondColor: UIColor {
        return UIColor(red: 0.2, green: 0.71, blue: 0.52, alpha: 1)
    }
    override var thirdColor: UIColor {
        return UIColor(red: 0.12, green: 0.15, blue: 0.23, alpha: 1)
    }
}

class OnboardingPage5ViewController : OnboardingPageGradientViewController {
    override var firstColor: UIColor {
        return UIColor(red: 0.74, green: 0.46, blue: 0.96, alpha: 1)
    }
    override var secondColor: UIColor {
        return UIColor(red: 0.37, green: 0.18, blue: 0.52, alpha: 1)
    }
    override var thirdColor: UIColor {
        return UIColor(red: 0.12, green: 0.15, blue: 0.23, alpha: 1)
    }
}

class OnboardingPage6ViewController : OnboardingPageGradientViewController {
    override var firstColor: UIColor {
        return UIColor(red: 0.2, green: 0.13, blue: 0.87, alpha: 1)
    }
    override var secondColor: UIColor {
        return UIColor(red: 0.16, green: 0.11, blue: 0.56, alpha: 1)
    }
    override var thirdColor: UIColor {
        return UIColor(red: 0.12, green: 0.15, blue: 0.23, alpha: 1)
    }
}
