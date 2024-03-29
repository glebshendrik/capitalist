//
//  FormTapField.swift
//  Capitalist
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
    
    @IBInspectable var arrowImage: UIImage? = UIImage(named: "arrow-right-small-icon") {
        didSet { updateArrow() }
    }
    
    @IBInspectable var arrowColor: UIColor = UIColor.by(.white40) {
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
            make.right.equalTo(arrow.snp.left).offset(-10)
            make.centerY.equalToSuperview().offset(3)
        }
        subValueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        subValueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    func setupArrowConstraints() {
        arrow.snp.makeConstraints { make in            
            make.right.equalTo(-16)
            make.centerY.equalToSuperview().offset(3)
            make.width.equalTo(6)
            make.height.equalTo(11)
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
        arrow.image = arrowImage?.withRenderingMode(.alwaysTemplate)
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
