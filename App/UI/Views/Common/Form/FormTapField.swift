//
//  FormTapField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 29/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class FormTapField : FormTextField {
    lazy var tapButton: UIButton = { return UIButton() }()
    
    lazy var arrow: UIImageView = { return UIImageView() }()
    
    @IBInspectable var arrowImageName: String = "right-arrow-icon" {
        didSet { updateArrow() }
    }
    
    @IBInspectable var arrowColor: UIColor = UIColor.by(.dark404B6F) {
        didSet { updateArrow() }
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        setupTapButton()
        setupArrow()
    }
    
    override func updateSubviews() {
        super.updateSubviews()
        updateTapButton()
        updateArrow()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        tapButton.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        
        arrow.snp.makeConstraints { make in
            make.left.equalTo(textField.snp.right).offset(5)
            make.centerY.equalToSuperview().offset(3)
        }
    }
    
    func setupTapButton() {
        tapButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tapButton)
        tapButton.backgroundColor = .clear
    }
    
    func updateTapButton() {
        tapButton.isEnabled = isEnabled
        tapButton.isUserInteractionEnabled = isEnabled
    }
    
    func setupArrow() {
        arrow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrow)
    }
    
    func updateArrow() {
        arrow.image = UIImage(named: arrowImageName)?.withRenderingMode(.alwaysTemplate)
        arrow.tintColor = arrowColor
        arrow.isHidden = !isEnabled
    }
}
