//
//  DependentIncomeSourceCreationMessageViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 23/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import BEMCheckBox

class DependentIncomeSourceInfoViewController : UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var basketImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    var activeName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    @IBAction func didTapGetItButton(_ sender: Any) {
        if checkBox.on {
            _ = UIFlowManager.reach(point: .dependentIncomeSourceMessage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        checkBox.boxType = .square
    }
    
    private func updateUI() {
        titleLabel.text = title()
        messageLabel.text = message()
    }
    
    private func title() -> String? {
        return "Мы создали источник дохода для актива «\(activeName)»"
    }
    
    private func message() -> String? {
        return "С помощью него ты сможешь отразить доход по активу"
    }
}
