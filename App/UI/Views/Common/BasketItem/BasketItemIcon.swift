//
//  BasketItemIcon.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 20/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import AlamofireImage
import SnapKit

class BasketItemIcon : BasketItemView {
    lazy var backgroundView: UIView = { return UIImageView() }()
    lazy var iconImageView: UIImageView = { return UIImageView() }()
    
    var backgroundCornerRadius: CGFloat = 0.0 {
        didSet {
            backgroundView.cornerRadius = backgroundCornerRadius
            cornerRadius = backgroundCornerRadius
        }
    }
    
    var iconTintColor: UIColor = UIColor.by(.white100) {
        didSet {
            iconImageView.tintColor = iconTintColor
        }
    }
    
    var defaultIconName: String? = nil {
        didSet {
            updateIcon()
        }
    }
    
    var backgroundViewColor: UIColor? = nil {
        didSet {
            backgroundView.backgroundColor = backgroundViewColor
        }
    }
        
    var iconURL: URL? = nil {
        didSet {
            updateIcon()
        }
    }
    
    //
    override func setup() {
        super.setup()
        setupBackgroundView()
        setupIcon()
    }
        
    override func setupConstraints() {
        setupBackgroundConstraints()
        setupIconConstraints()
    }
    
    // Setup
    private func setupBackgroundView() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.cornerRadius = backgroundCornerRadius
        addSubview(backgroundView)
    }
    
    private func setupIcon() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
    }
        
    private func updateIcon() {
        iconImageView.setImage(with: iconURL,
                               placeholderName: defaultIconName,
                               renderingMode: .alwaysTemplate)
    }
    
    // Constraints
    func setupBackgroundConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    func setupIconConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.width.height.lessThanOrEqualTo(22)
            make.center.equalToSuperview()
        }
    }
}
