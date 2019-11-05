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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if checkBox.on {
            _ = UIFlowManager.reach(point: .dependentIncomeSourceMessage)
        }
    }
    
    @IBAction func didTapGetItButton(_ sender: Any) {
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
        return "Актив «\(activeName)» может приносить прибыль"
    }
    
    private func message() -> String? {
        return "Поэтому мы создаем для вас новый источник дохода «\(activeName)»"
    }
}
