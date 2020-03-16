//
//  StartAnimationViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03.03.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import SwiftyGif

class StartAnimationViewController : UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
        
    func startAnimationWith(delegate: SwiftyGifDelegate) throws {
        let gif = try UIImage(gifName: "launch-animation.gif")
        imageView.setGifImage(gif, manager: SwiftyGifManager.defaultManager, loopCount: 1)
        imageView.delegate = delegate
    }
}
