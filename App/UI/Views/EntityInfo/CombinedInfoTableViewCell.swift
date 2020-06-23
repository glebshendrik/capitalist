//
//  HeaderInfoTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol CombinedInfoTableViewCellDelegate : EntityInfoTableViewCellDelegate {
    func didTapIcon(field: IconInfoField?)
    func didTapInfoField(field: BasicInfoField?)
}

class CombinedInfoTableViewCell : EntityInfoTableViewCell {
    @IBOutlet weak var iconFieldView: UIView!
    @IBOutlet weak var iconView: IconView!
    
    @IBOutlet weak var basicFieldsStackView: UIStackView!
    
    @IBOutlet weak var mainFieldView: UIView!
    @IBOutlet weak var mainFieldValueLabel: UILabel!
    @IBOutlet weak var mainFieldTitleLabel: UILabel!
    
    @IBOutlet weak var basicSubFieldsStackView: UIStackView!
    
    @IBOutlet weak var firstFieldView: UIView!
    @IBOutlet weak var firstFieldValueLabel: UILabel!
    @IBOutlet weak var firstFieldTitleLabel: UILabel!
    
    @IBOutlet weak var secondFieldView: UIView!
    @IBOutlet weak var secondFieldValueLabel: UILabel!
    @IBOutlet weak var secondFieldTitleLabel: UILabel!
    
    @IBOutlet weak var thirdFieldView: UIView!
    @IBOutlet weak var thirdFieldValueLabel: UILabel!
    @IBOutlet weak var thirdFieldTitleLabel: UILabel!
    
    var combinedInfoDelegate: CombinedInfoTableViewCellDelegate? {
        return delegate as? CombinedInfoTableViewCellDelegate
    }
    
    var combinedField: CombinedInfoField? {
        return field as? CombinedInfoField
    }
    
    override func updateUI() {
        updateFieldsVisibility()
        updateIconFieldUI()
        updateMainFieldUI()
        updateFirstFieldUI()
        updateSecondFieldUI()
        updateThirdFieldUI()
    }
        
    func updateFieldsVisibility() {
        guard let field = combinedField else {
            iconFieldView.isHidden = true
            basicFieldsStackView.isHidden = true
            return
        }
        iconFieldView.isHidden = field.isIconFieldHidden
        basicFieldsStackView.isHidden = field.areBasicFieldsHidden
        mainFieldView.isHidden = field.isMainFieldHidden
        basicSubFieldsStackView.isHidden = field.areBasicSubFieldsHidden
        firstFieldView.isHidden = field.isFirstFieldHidden
        secondFieldView.isHidden = field.isSecondFieldHidden
        thirdFieldView.isHidden = field.isThirdFieldHidden
    }
    
    func updateIconFieldUI() {
        guard   let field = combinedField,
                let iconField = field.iconInfoField else { return }
        iconView.vectorIconMode = .fullsize
        iconView.iconURL = iconField.iconURL
        iconView.defaultIconName = iconField.placeholder
        iconView.iconTintColor = UIColor.by(.white100)
        iconView.backgroundViewColor = iconField.backgroundColor
    }
    
    func updateMainFieldUI() {
        guard   let field = combinedField,
                let mainInfoField = field.mainInfoField else { return }
        mainFieldTitleLabel.text = mainInfoField.title
        mainFieldValueLabel.text = mainInfoField.value
        mainFieldValueLabel.textColor = UIColor.by(mainInfoField.valueColorAsset)
    }
    
    func updateFirstFieldUI() {
        guard   let field = combinedField,
                let firstInfoField = field.firstInfoField else { return }
        firstFieldTitleLabel.text = firstInfoField.title
        firstFieldValueLabel.text = firstInfoField.value
        firstFieldValueLabel.textColor = UIColor.by(firstInfoField.valueColorAsset)
    }
    
    func updateSecondFieldUI() {
        guard   let field = combinedField,
                let secondInfoField = field.secondInfoField else { return }
        secondFieldTitleLabel.text = secondInfoField.title
        secondFieldValueLabel.text = secondInfoField.value
        secondFieldValueLabel.textColor = UIColor.by(secondInfoField.valueColorAsset)
    }
    
    func updateThirdFieldUI() {
        guard   let field = combinedField,
                let thirdInfoField = field.thirdInfoField else { return }
        thirdFieldTitleLabel.text = thirdInfoField.title
        thirdFieldValueLabel.text = thirdInfoField.value
        thirdFieldValueLabel.textColor = UIColor.by(thirdInfoField.valueColorAsset)
    }
    
    @IBAction func didTapIcon(_ sender: Any) {
        combinedInfoDelegate?.didTapIcon(field: combinedField?.iconInfoField)
    }
    
    @IBAction func didTapMainField(_ sender: Any) {
        combinedInfoDelegate?.didTapInfoField(field: combinedField?.mainInfoField)
    }
    
    @IBAction func didTapFirstField(_ sender: Any) {
        combinedInfoDelegate?.didTapInfoField(field: combinedField?.firstInfoField)
    }
    
    @IBAction func didTapSecondField(_ sender: Any) {
        combinedInfoDelegate?.didTapInfoField(field: combinedField?.secondInfoField)
    }
    
    @IBAction func didTapThirdField(_ sender: Any) {
        combinedInfoDelegate?.didTapInfoField(field: combinedField?.thirdInfoField)
    }
}

