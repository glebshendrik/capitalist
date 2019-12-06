//
//  TransactionCreationInfoViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 06.12.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import BEMCheckBox

class TransactionCreationInfoViewController : UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if checkBox.on {
            _ = UIFlowManager.reach(point: .transactionCreationInfoMessage)
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
        return "Выберите Источник и Назначение для отображения транзакции"
    }
    
    private func message() -> String? {
        return "Для выбора элемента нажмите на него. Чтобы снять выбор, нажмите еще раз"
    }
}
