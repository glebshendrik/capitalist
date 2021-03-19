//
//  OnboardingWelcomeViewController.swift
//  Capitalist
//
//  Created by Gleb Shendrik on 19.03.2021.
//  Copyright © 2021 Real Tranzit. All rights reserved.
//

import UIKit
import AVKit

class OnboardingWelcomeViewController: UIViewController {
    
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var playVideoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onTapPlayVideo(_ sender: UIButton) {
        let videoURL: URL = Bundle.main.url(forResource: "video-sample", withExtension: "mp4")!
        let player = AVPlayer(url: videoURL)
        let avPlayerViewController = AVPlayerViewController()
        avPlayerViewController.player = player
        avPlayerViewController.showsPlaybackControls = true
        avPlayerViewController.videoGravity = .resizeAspectFill
        avPlayerViewController.modalPresentationStyle = .fullScreen
        modal(avPlayerViewController)
        player.play()
    }
    
    
    @IBAction func onTapClose(_ sender: UIButton) {
        
    }
    
    
}
