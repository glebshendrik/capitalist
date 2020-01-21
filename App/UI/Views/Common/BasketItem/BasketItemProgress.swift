//
//  BasketItemProgress.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 20/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class BasketItemProgress : BasketItemView {
    lazy var progressView: UIView = { return UIView() }()
    lazy var limitLabel: UILabel = { return UILabel() }()
        
    var backgroundCornerRadius: CGFloat = 0.0 {
        didSet {
            cornerRadius = backgroundCornerRadius
        }
    }
    
    var labelColor: UIColor = UIColor.by(.white100) {
        didSet {
            limitLabel.textColor = labelColor
        }
    }
    
    var labelFont: UIFont? = UIFont(name: "Roboto-Regular", size: 12) {
        didSet {
            limitLabel.font = labelFont
        }
    }
    
    var progressColor: UIColor = .clear {
        didSet {
            progressView.backgroundColor = progressColor
        }
    }
    
    var progressWidth: CGFloat = 0.0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
                
    var text: String? = nil {
        didSet {
            limitLabel.text = text
        }
    }
    
    override func setup() {
        super.setup()
        backgroundColor = UIColor.clear
        setupProgress()
        setupLabel()
    }
        
    override func setupConstraints() {
        setupProgressConstraints()
        setupLimitLabelConstraints()
    }
    
    override func updateConstraints() {
        if didSetupConstraints {
            updateProgressConstraints()
        }
        super.updateConstraints()
    }
        
    private func setupProgress() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
    }
    
    private func setupLabel() {
        limitLabel.translatesAutoresizingMaskIntoConstraints = false
        limitLabel.textAlignment = .center
        limitLabel.font = labelFont
        limitLabel.adjustsFontSizeToFitWidth = true
        limitLabel.text = text
        addSubview(limitLabel)
    }
        
    func setupProgressConstraints() {
        progressView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(progressWidth)
        }
    }
    
    func updateProgressConstraints() {        
        progressView.snp.updateConstraints { make in
            make.width.equalTo(progressWidth)
        }
    }
    
    func setupLimitLabelConstraints() {
        limitLabel.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
}
