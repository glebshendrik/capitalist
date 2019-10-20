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
    lazy var backgroundImageView: UIImageView = { return UIImageView() }()
    lazy var iconImageView: UIImageView = { return UIImageView() }()
    
    var backgroundCornerRadius: CGFloat = 0.0 {
        didSet {
            backgroundImageView.cornerRadius = backgroundCornerRadius
            cornerRadius = backgroundCornerRadius
        }
    }
    
    var iconTintColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet {
            iconImageView.tintColor = iconTintColor
        }
    }
    
    var defaultIconName: String? = nil {
        didSet {
            updateIcon()
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
    
    var iconURL: URL? = nil {
        didSet {
            updateIcon()
        }
    }
    
    //
    override func setup() {
        super.setup()
        setupBackgroundImageView()
        setupIcon()
    }
        
    override func setupConstraints() {
        setupBackgroundConstraints()
        setupIconConstraints()
    }
    
    // Setup
    private func setupBackgroundImageView() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.cornerRadius = backgroundCornerRadius
        addSubview(backgroundImageView)
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
        backgroundImageView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    func setupIconConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.width.height.lessThanOrEqualTo(20)
            make.center.equalToSuperview()
        }
    }
}
