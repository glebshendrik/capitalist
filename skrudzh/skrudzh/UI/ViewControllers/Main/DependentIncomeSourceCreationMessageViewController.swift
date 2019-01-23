//
//  DependentIncomeSourceCreationMessageViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 23/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import BEMCheckBox

class DependentIncomeSourceCreationMessageViewController : UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var basketImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    var basketType: BasketType = .risk
    var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    @IBAction func didTapGetItButton(_ sender: Any) {
        if checkBox.on, let point = uiPoint() {
            _ = UIFlowManager.reach(point: point)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func updateUI() {
        titleLabel.text = title()
        basketImageView.image = basketImage()
        messageLabel.text = message()
    }
    
    private func title() -> String? {
        switch basketType {
        case .risk:
            return "Категория трат «\(name)» относится к корзине «Риски», она может приносить прибыль"
        case .safe:
            return "Категория трат «\(name)» относится к корзине «Безопасность», она может приносить прибыль"
        default:
            return nil
        }
    }
    
    private func basketImage() -> UIImage? {
        switch basketType {
        case .risk:
            return UIImage(named: "risk-large-image")
        case .safe:
            return UIImage(named: "safe-large-image")
        default:
            return nil
        }
    }
    
    private func message() -> String? {
        return "Поэтому мы создаем для вас новый источник дохода «\(name)»"
    }
    
    private func uiPoint() -> UIFlowPoint? {
        switch basketType {
        case .risk:
            return .dependentRiskIncomeSourceMessage
        case .safe:
            return .dependentSafeIncomeSourceMessage
        default:
            return nil
        }
    }
}
