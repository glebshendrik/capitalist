//
//  IconView.swift
//  Capitalist
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
    case medium
    case compact
}

class IconView : CustomView {
    lazy var backgroundView: UIView = { return UIView() }()
    lazy var rasterImageView: UIImageView = { return UIImageView() }()
    lazy var vectorBackgroundView: UIView = { return UIView() }()
    lazy var vectorImageView: SVGKFastImageView = { return SVGKFastImageView(frame: CGRect.zero) }()
        
    var iconType: IconType {
        return iconURL?.iconType ?? .raster
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
    
    var backgroundCornerRadius: CGFloat? = nil {
        didSet {
            updateSizeDependentProperties()
        }
    }
        
    var backgroundViewColor: UIColor = .clear {
        didSet {
            updateBackgroundColor()
        }
    }
    
    var vectorBackgroundViewColor: UIColor = UIColor.by(.white100) {
        didSet {
            updateVectorBackgroundColor()
        }
    }
    
    var vectorIconMode: VectorIconMode = .fullsize {
        didSet {
            updateIcons()
            updateVectorConstraints()
        }
    }
    
    private var vectorFullsizeConstraints: [Constraint] = []
    private var vectorMediumConstraints: [Constraint] = []
    private var vectorCompactConstraints: [Constraint] = []
    
    override func setup() {
        super.setup()
        setupBackgroundView()
        setupRasterIcon()
        setupVectorBackgroundView()
        setupVectorIcon()
        updateBackgroundColor()
        updateVectorBackgroundColor()
        updateVectorConstraints()
        updateSizeDependentProperties()
    }
        
    override func setupConstraints() {
        setupBackgroundConstraints()
        setupRasterIconConstraints()
        setupVectorIconConstraints()
        setupVectorBackgroundConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSizeDependentProperties()
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
    
    private func setupVectorBackgroundView() {
        vectorBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vectorBackgroundView)
    }
    
    private func setupVectorIcon() {
        vectorImageView.translatesAutoresizingMaskIntoConstraints = false
        vectorBackgroundView.addSubview(vectorImageView)
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
        vectorBackgroundView.isHidden = iconType != .vector
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
            vectorFullsizeConstraints.append(make.width.height.equalTo(32).constraint)
            vectorMediumConstraints.append(make.width.height.equalTo(30).constraint)
            vectorCompactConstraints.append(make.width.height.equalTo(18).constraint)
            make.center.equalToSuperview()
        }
    }
    
    func setupVectorBackgroundConstraints() {
        vectorBackgroundView.snp.makeConstraints { make in
            vectorFullsizeConstraints.append(make.left.top.right.bottom.equalToSuperview().constraint)
            vectorMediumConstraints.append(make.width.height.equalTo(36).constraint)
            vectorMediumConstraints.append(make.center.equalToSuperview().constraint)
            vectorCompactConstraints.append(make.width.height.equalTo(24).constraint)
            vectorCompactConstraints.append(make.center.equalToSuperview().constraint)
        }
    }
    
    private func setVectorFullsizeConstraints(active: Bool) {
        vectorFullsizeConstraints.forEach { $0.isActive = active }
    }
    
    private func setMediumCompactConstraints(active: Bool) {
        vectorMediumConstraints.forEach { $0.isActive = active }
    }
    
    private func setVectorCompactConstraints(active: Bool) {
        vectorCompactConstraints.forEach { $0.isActive = active }
    }
    
    private func updateSizeDependentProperties() {
        backgroundView.cornerRadius = backgroundCornerRadius ?? backgroundView.bounds.size.width / 2.0
        vectorBackgroundView.cornerRadius = vectorBackgroundView.bounds.size.width / 2.0
        cornerRadius = backgroundCornerRadius ?? bounds.size.width / 2.0
    }
    
    private func updateIconTint() {
        rasterImageView.tintColor = iconTintColor
    }
    
    private func updateBackgroundColor() {
        backgroundView.backgroundColor = backgroundViewColor
    }
    
    private func updateVectorBackgroundColor() {
        vectorBackgroundView.backgroundColor = vectorBackgroundViewColor
    }
    
    private func updateVectorConstraints() {
        setVectorFullsizeConstraints(active: vectorIconMode == .fullsize)
        setMediumCompactConstraints(active: vectorIconMode == .medium)
        setVectorCompactConstraints(active: vectorIconMode == .compact)
        self.updateConstraints()
        self.layoutIfNeeded()
    }
}
