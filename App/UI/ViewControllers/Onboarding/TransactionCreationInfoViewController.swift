//
//  TransactionCreationInfoViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 06.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class TransactionCreationInfoViewController : UIViewController {    
    @IBOutlet weak var tutorialImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialImageView.showTutorial()
        setupNavigationBarAppearance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = UIFlowManager.reach(point: .transactionCreationInfoMessage)
    }
    
    @IBAction func didTapGetItButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
