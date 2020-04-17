//
//  IconView.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 15.04.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import SDWebImageSVGCoder
import SVGKit
import AlamofireImage
import SnapKit

enum IconType {
    case raster
    case vector
}

enum VectorIconMode {
    case fullsize
    case compact
}

class IconView : CustomView {
    lazy var backgroundView: UIView = { return UIImageView() }()
    lazy var rasterImageView: UIImageView = { return UIImageView() }()
    lazy var vectorImageView: SVGKFastImageView = { return SVGKFastImageView() }()
    lazy var vectorBackgroundView: UIView = { return UIImageView() }()
    
    var iconType: IconType = .raster {
        didSet {
            updateIcons()
        }
    }
    
    var iconURL: URL? = nil {
        didSet {
            updateIcons()
        }
    }
    
    var iconTintColor: UIColor = UIColor.by(.white100) {
        didSet {
            updateIconTint()
        }
    }
    
    var defaultIconName: String? = nil {
        didSet {
            updateIcons()
        }
    }
    
    var backgroundViewColor: UIColor? = nil {
        didSet {
            updateBackgroundColor()
        }
    }
    
    
    
    
    
    override func setup() {
        super.setup()
        setupBackgroundView()
        setupRasterIcon()
        setupVectorIcon()
        updateSizeDependentProperties()
    }
        
    override func setupConstraints() {
        setupBackgroundConstraints()
        setupRasterIconConstraints()
        setupVectorIconConstraints()
    }
    
    // Setup
    private func setupBackgroundView() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
    }
    
    private func setupRasterIcon() {
        rasterImageView.translatesAutoresizingMaskIntoConstraints = false
        rasterImageView.contentMode = .scaleAspectFit
        addSubview(rasterImageView)
    }
    
    private func setupVectorIcon() {
        vectorImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vectorImageView)
    }
     
    private func updateIcons() {
        updateRasterIconImage()
        updateVectorIconImage()
        
        
    }
    
    private func updateRasterIconImage() {
        rasterImageView.isHidden = iconType != .raster
        rasterImageView.setImage(with: iconURL,
                                 placeholderName: defaultIconName,
                                 renderingMode: .alwaysTemplate)
        updateIconTint()
    }
    
    private func updateVectorIconImage() {
        vectorImageView.isHidden = iconType != .vector
        vectorImageView.sd_setImage(with: iconURL, completed: nil)
    }
    
    
    
    // Constraints
    func setupBackgroundConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    
    
    func setupRasterIconConstraints() {
        rasterImageView.snp.makeConstraints { make in
            make.width.height.lessThanOrEqualTo(22)
            make.center.equalToSuperview()
        }
    }
    
    func setupVectorIconConstraints() {
        vectorImageView.snp.makeConstraints { make in
            make.width.height.lessThanOrEqualTo(22)
            make.center.equalToSuperview()
        }
    }
    
    private func updateSizeDependentProperties() {
        backgroundView.cornerRadius = backgroundView.bounds.size.width / 2.0
        cornerRadius = bounds.size.width / 2.0
    }
    
    private func updateIconTint() {
        rasterImageView.tintColor = iconTintColor
    }
    
    private func updateBackgroundColor() {
        backgroundView.backgroundColor = backgroundViewColor
    }
}
