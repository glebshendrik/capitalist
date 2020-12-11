//
//  TransactionCreationInfoViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 06.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SwiftyGif

class TransactionCreationInfoViewController : UIViewController, Away {
    weak var home: Home?
    
    @IBOutlet weak var tutorialImageView: UIImageView!
    
    var id: String {
        return Infrastructure.ViewController.TransactionCreationInfoViewController.identifier
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        showTutorial()
        setupNavigationBarAppearance()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _ = UIFlowManager.reach(point: .transactionCreationInfoMessage)
        home?.cameHome(from: .TransactionCreationInfoViewController)
    }
    
    @IBAction func didTapGetItButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func showTutorial() {
        if let gif = try? UIImage(gifName: NSLocalizedString("drag-tutorial", comment: "drag-tutorial")) {
            tutorialImageView.setGifImage(gif, manager: SwiftyGifManager.defaultManager, loopCount: -1)
        }
    }
}
