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
    lazy var backgroundImageView: UIImageView = { return UIImageView() }()
    lazy var progressView: UIView = { return UIView() }()
    lazy var limitLabel: UILabel = { return UILabel() }()
        
    var backgroundCornerRadius: CGFloat = 0.0 {
        didSet {
            backgroundImageView.cornerRadius = backgroundCornerRadius
            cornerRadius = backgroundCornerRadius
        }
    }
    
    var labelColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet {
            limitLabel.textColor = labelColor
        }
    }
    
    var labelFont: UIFont? = UIFont(name: "Roboto-Regular", size: 9) {
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
    
    var backgroundImage: UIImage? = nil {
        didSet {
            backgroundImageView.image = backgroundImage
        }
    }
    
    var isBackgroundHidden: Bool = false {
        didSet {
            backgroundImageView.isHidden = isBackgroundHidden
        }
    }
    
    var isProgressHidden: Bool = false {
        didSet {
            progressView.isHidden = isProgressHidden
        }
    }
    
    var text: String? = nil {
        didSet {
            limitLabel.text = text
        }
    }
    
    override func setup() {
        super.setup()
        backgroundColor = UIColor.by(.textFFFFFF)
        setupBackground()
        setupProgress()
        setupLabel()
    }
        
    override func setupConstraints() {
        setupBackgroundImageViewConstraints()
        setupProgressConstraints()
        setupLimitLabelConstraints()
    }
    
    override func updateConstraints() {
        if didSetupConstraints {
            updateProgressConstraints()
        }
        super.updateConstraints()
    }
    
    private func setupBackground() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = backgroundImage
        backgroundImageView.isHidden = isBackgroundHidden
        addSubview(backgroundImageView)
    }
    
    private func setupProgress() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = isProgressHidden
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
    
    func setupBackgroundImageViewConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
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
