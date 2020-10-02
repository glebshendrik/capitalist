//
//  ExperimentalBankFeatureViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 02.10.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol ExperimentalBankFeatureViewControllerDelegate : class {
    func didChooseUseFeature()
    func didChooseDontUseFeature()
}

class ExperimentalBankFeatureViewController : UIViewController {
    weak var delegate: ExperimentalBankFeatureViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
    }
    
    @IBAction func didTapUseFeature(_ sender: Any) {
        delegate?.didChooseUseFeature()
        closeButtonHandler()
    }
    
    @IBAction func didTapDontUseFeature(_ sender: Any) {
        delegate?.didChooseDontUseFeature()
        closeButtonHandler()
    }
}
