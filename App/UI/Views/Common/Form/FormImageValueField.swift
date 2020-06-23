//
//  FormImageValueField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class FormImageValueField : FormTapField {
    lazy var imageView: UIImageView = { return UIImageView() }()
    
    var valueImageURL: URL? {
        didSet {
            updateImage()
        }
    }
    
    var valueImagePlaceholder: String? {
        didSet {
            updateImage()
        }
    }
    
    var valueImageName: String? {
        didSet {
            updateImage()
        }
    }
        
    override func setupSubviews() {
        super.setupSubviews()
        setupImage()
    }
    
    override func updateSubviews() {
        super.updateSubviews()
        updateImage()
    }
        
    override func setupConstraints() {
        super.setupConstraints()
        setupImageConstraints()
    }
    
    func setupImageConstraints() {
        imageView.snp.makeConstraints { make in
            make.right.equalTo(arrow.snp.left).offset(-16)
            make.width.lessThanOrEqualTo(50)
            make.centerY.equalToSuperview().offset(3)
        }
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    override func setupTextFieldConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.right.equalTo(imageView.snp.left).offset(8)
            make.bottom.equalTo(-16)
            make.left.equalTo(icon.snp.right).offset(20)
        }
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupImage() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
    }
    
    func updateImage() {
        if let imageName = valueImageName {
            imageView.image = UIImage(named: imageName)
        }
        else {
            imageView.image = nil
            imageView.setImage(with: valueImageURL, placeholderName: valueImagePlaceholder)
        }
    }
        
    override func updateSubValueLabel() {
        super.updateSubValueLabel()
        subValueLabel.isHidden = true
    }
}
