//
//  ProgressView.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 06/11/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class ProgressView : CustomView {
    lazy var progressView: UIView = { return UIView() }()
    lazy var limitLabel: UILabel = { return UILabel() }()
    lazy var progressLabel: UILabel = { return UILabel() }()
    
    var labelsColor: UIColor = UIColor.by(.white100) {
        didSet {
            limitLabel.textColor = labelsColor
            progressLabel.textColor = labelsColor
        }
    }
    
    var labelsFont: UIFont? = UIFont(name: "Roboto-Light", size: 13) {
        didSet {
            limitLabel.font = labelsFont
            progressLabel.font = labelsFont
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
    
    var limitText: String? = nil {
        didSet {
            limitLabel.text = limitText
        }
    }
    
    var progressText: String? = nil {
        didSet {
            progressLabel.text = progressText
        }
    }
    
    override func setup() {
        super.setup()
        setupProgress()
        setupLimitLabel()
        setupProgressLabel()
    }
        
    override func setupConstraints() {
        setupProgressConstraints()
        setupLimitLabelConstraints()
        setupProgressLabelConstraints()
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
    
    private func setupLimitLabel() {
        limitLabel.translatesAutoresizingMaskIntoConstraints = false
        limitLabel.textAlignment = .right
        limitLabel.font = labelsFont
        limitLabel.adjustsFontSizeToFitWidth = true
        limitLabel.text = limitText
        addSubview(limitLabel)
    }
    
    private func setupProgressLabel() {
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.textAlignment = .left
        progressLabel.font = labelsFont
        progressLabel.adjustsFontSizeToFitWidth = true
        progressLabel.text = progressText
        addSubview(progressLabel)
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
            make.right.equalToSuperview().offset(-8)
            make.top.bottom.equalToSuperview()
        }
        limitLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        limitLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupProgressLabelConstraints() {
        progressLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(limitLabel.snp.left)
        }
        
    }
}
