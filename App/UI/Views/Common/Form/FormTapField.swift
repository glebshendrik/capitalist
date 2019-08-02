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
    private var didTap: (() -> Void)? = nil
    
    lazy var tapButton: UIButton = { return UIButton() }()
    
    lazy var arrow: UIImageView = { return UIImageView() }()
    
    @IBInspectable var arrowImageName: String = "right-arrow-icon" {
        didSet { updateArrow() }
    }
    
    @IBInspectable var arrowColor: UIColor = UIColor.by(.dark404B6F) {
        didSet { updateArrow() }
    }
    
    func didTap(_ didTap: @escaping () -> Void) {
        self.didTap = didTap
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
        setupTapButtonConstraints()
        setupArrowConstraints()
    }
    
    func setupTapButtonConstraints() {
        tapButton.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    override func setupSubValueLabelConstraints() {
        subValueLabel.snp.makeConstraints { make in
            make.right.equalTo(arrow.snp.left).offset(5)
            make.centerY.equalTo(3)
        }
        subValueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        subValueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    func setupArrowConstraints() {
        arrow.snp.makeConstraints { make in            
            make.right.equalTo(-16)
            make.centerY.equalTo(3)
        }
    }
    
    func setupTapButton() {
        tapButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tapButton)
        tapButton.backgroundColor = .clear
        tapButton.addTarget(self, action: #selector(didButtonTouchUpInside(_:)), for: UIControl.Event.touchUpInside)
    }
    
    override func updateTextField() {
        super.updateTextField()
        textField.isEnabled = false
        textField.isUserInteractionEnabled = false
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
    
    func tap() {
        guard isEnabled else { return }
        didTap?()
    }
    
    @objc private func didButtonTouchUpInside(_ sender: Any) {
        tap()
    }
}
