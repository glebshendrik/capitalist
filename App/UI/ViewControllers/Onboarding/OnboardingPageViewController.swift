//
//  OnboardingPageViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class OnboardingPageGradientViewController : UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        parent?.view.backgroundColor = UIColor.by(.black2)
    }    
}

class OnboardingPage4ViewController : OnboardingPageGradientViewController {
}

class OnboardingPage5ViewController : OnboardingPageGradientViewController {
}

class OnboardingPage6ViewController : OnboardingPageGradientViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.parent?.view.backgroundColor = UIColor.by(.black2)
    }
}
