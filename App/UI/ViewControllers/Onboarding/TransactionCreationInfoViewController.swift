//
//  TransactionCreationInfoViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 06.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SwiftyGif

class TransactionCreationInfoViewController : UIViewController {    
    @IBOutlet weak var tutorialImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        showTutorial()
        setupNavigationBarAppearance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = UIFlowManager.reach(point: .transactionCreationInfoMessage)
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
