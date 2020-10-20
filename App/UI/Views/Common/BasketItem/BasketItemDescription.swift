//
//  BasketItemDescription.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 20/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class BasketItemDescription : CustomView {
    lazy var titleLabel: UILabel = { return UILabel() }()
    lazy var amountLabel: UILabel = { return UILabel() }()
    lazy var subAmountLabel: UILabel = { return UILabel() }()
    
    var titleColor: UIColor = UIColor.by(.white64) {
        didSet {
            titleLabel.textColor = titleColor
        }
    }
    
    var amountColor: UIColor = UIColor.by(.white100) {
        didSet {
            amountLabel.textColor = amountColor
        }
    }
    
    var subAmountColor: UIColor = UIColor.by(.white64) {
        didSet {
            subAmountLabel.textColor = subAmountColor
        }
    }
    
    var titleFont: UIFont? = UIFont(name: "Roboto-Light", size: 12) {
        didSet {
            titleLabel.font = titleFont
        }
    }
    
    var amountFont: UIFont? = UIFont(name: "Roboto-Regular", size: 16) {
        didSet {
            amountLabel.font = amountFont
        }
    }
    
    var subAmountFont: UIFont? = UIFont(name: "Roboto-Light", size: 12) {
        didSet {
            subAmountLabel.font = subAmountFont
        }
    }
        
    var titleText: String? = nil {
        didSet {            
            titleLabel.text = titleText
        }
    }
    
    var amountText: String? = nil {
        didSet {
            amountLabel.text = amountText
        }
    }
    
    var subAmountText: String? = nil {
        didSet {
            subAmountLabel.text = subAmountText
        }
    }
    
    var isSubAmountHidden: Bool = true {
        didSet {
            subAmountLabel.isHidden = isSubAmountHidden
        }
    }
    
    override func setup() {
        super.setup()
        setupTitle()
        setupAmount()
        setupSubAmount()
    }
        
    func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = titleFont
        titleLabel.textAlignment = .center
        titleLabel.textColor = titleColor
        titleLabel.text = titleText
        addSubview(titleLabel)

    }
    
    func setupAmount() {
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.font = amountFont
        amountLabel.textColor = amountColor
        amountLabel.textAlignment = .center
        amountLabel.text = amountText
        addSubview(amountLabel)

    }
    
    func setupSubAmount() {
        subAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        subAmountLabel.font = subAmountFont
        subAmountLabel.textColor = subAmountColor
        subAmountLabel.textAlignment = .center
        subAmountLabel.text = subAmountText
        subAmountLabel.isHidden = isSubAmountHidden
        addSubview(subAmountLabel)
    }
    
    override func setupConstraints() {
        setupTitleConstraints()
        setupAmountConstraints()
        setupSubAmountConstraints()
    }
    
    func setupTitleConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    func setupAmountConstraints() {
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(1)
            make.left.right.equalToSuperview()
        }
        amountLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        amountLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    func setupSubAmountConstraints() {
        subAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(0)
//            make.bottom.greaterThanOrEqualToSuperview().offset(0)
            make.left.right.equalToSuperview()
        }
        subAmountLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        subAmountLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
}
