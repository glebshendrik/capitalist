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
            progressView.cornerRadius = backgroundCornerRadius
            cornerRadius = backgroundCornerRadius
        }
    }
    
    var labelColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet {
            limitLabel.textColor = labelColor
        }
    }
    
    var labelFont: UIFont? = UIFont(name: "Rubik-Regular", size: 9) {
        didSet {
            limitLabel.font = labelFont
        }
    }
    
    var progressColor: UIColor = .clear {
        didSet {
            progressView.backgroundColor = progressColor
        }
    }
    
    var progress: CGFloat = 0.0 {
        didSet {
            progressView.snp.remakeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.width.equalTo(self.frame.width * self.progress)
            }
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
    
    private func setupBackground() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = backgroundImage
        backgroundImageView.isHidden = isBackgroundHidden
        addSubview(backgroundImageView)
    }
    
    private func setupProgress() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.backgroundColor = UIColor.by(.riskF2D6FE)
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
            make.width.equalTo(self.frame.width * self.progress)
        }
    }
    
    func setupLimitLabelConstraints() {
        limitLabel.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
}
