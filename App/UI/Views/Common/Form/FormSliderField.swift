//
//  FormSliderField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class FormSliderField : FormTextField {
    private var didChange: ((Float) -> Void)? = nil
    
    lazy var baseContainer: UIView = { return UIView() }()
        
    lazy var slider: Slider = { return Slider() }()
    
    lazy var minimumValueLabel: UILabel = { return UILabel() }()
    
    lazy var maximumValueLabel: UILabel = { return UILabel() }()
    
    @IBInspectable var currentMinimumTrackImage: UIImage? = UIImage(named: "minimum-track-image") {
        didSet { updateSlider() }
    }
    
    @IBInspectable var currentMaximumTrackImage: UIImage? = UIImage(named: "maximum-track-image") {
        didSet { updateSlider() }
    }
    
    @IBInspectable var currentThumbImage: UIImage? = UIImage(named: "thumb") {
        didSet { updateSlider() }
    }
    
    @IBInspectable var minimumTrackTintColor: UIColor = UIColor.by(.blue5B86F7) {
        didSet { updateSlider() }
    }
    
    @IBInspectable var maximumTrackTintColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateSlider() }
    }
    
    @IBInspectable var thumbTintColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateSlider() }
    }
    
    @IBInspectable var minimumValue: Float = 0.0 {
        didSet {
            updateSlider()
            updateMinValueLabel()
        }
    }
    
    @IBInspectable var maximumValue: Float = 1.0 {
        didSet {
            updateSlider()
            updateMaxValueLabel()
        }
    }
    
    @IBInspectable var step: Float = 1.0 {
        didSet {
            updateSlider()
            updateMaxValueLabel()
            updateSliderValue(value)
        }
    }
    
    var value: Float {
        get { return slider.value }
        set { updateSliderValue(newValue) }
    }
    
    var valueFormatter: ((Float) -> String)? = nil {
        didSet {
            updateText()
            updateRangeLabels()
        }
    }
    
    @IBInspectable var rangeLabelColor: UIColor = UIColor.by(.text9EAACC) {
        didSet { updateRangeLabels() }
    }
    
    @IBInspectable var rangeLabelFont: UIFont = UIFont(name: "Rubik-Regular", size: 12)! {
        didSet { updateRangeLabels() }
    }
    
    func didChange(_ didChange: @escaping (Float) -> Void) {
        self.didChange = didChange
    }
    
    func convert(value: Float) -> Float {
        return Float(Int(value + step / 2))
    }
    
    func updateSliderValue(_ newValue: Float) {
        slider.value = convert(value: newValue)
        updateText()
    }
    
    func updateText() {
        text = formattedValue(value)
    }
    
    func formattedValue(_ value: Float) -> String {
        valueFormatter?(value) ?? "\(value)"
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        setupBaseContainer()
        setupSlider()
        setupMinValueLabel()
        setupMaxValueLabel()
    }
    
    override func updateSubviews() {
        super.updateSubviews()
        updateBaseContainer()
        updateSlider()
        updateMinValueLabel()
        updateMaxValueLabel()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        setupBaseContainerConstraints()
        setupSliderConstraints()
        setupMinValueLabelConstraints()
        setupMaxValueLabelConstraints()
    }
    
    // Setup
    override func setupIcon() {
        super.setupIcon()
        iconContainer.removeFromSuperview()
        baseContainer.addSubview(iconContainer)
    }
    
    override func setupTextField() {
        super.setupTextField()
        textField.removeFromSuperview()
        baseContainer.addSubview(textField)
    }
    
    override func setupSubValueLabel() {
        super.setupSubValueLabel()
        subValueLabel.removeFromSuperview()
        baseContainer.addSubview(subValueLabel)
    }
    
    func setupBaseContainer() {
        baseContainer.translatesAutoresizingMaskIntoConstraints = false
        baseContainer.backgroundColor = .clear
        addSubview(baseContainer)
    }
    
    func setupSlider() {
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)
        slider.addTarget(self, action: #selector(didSliderChangeValue(_:)), for: .valueChanged)
    }
    
    func setupMinValueLabel() {
        minimumValueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(minimumValueLabel)
    }
    
    func setupMaxValueLabel() {
        maximumValueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(maximumValueLabel)
    }
    
    // Update
    override func updateTextField() {
        super.updateTextField()
        textField.isUserInteractionEnabled = false
    }
    
    func updateBaseContainer() { }
    
    func updateSlider() {
        slider.isEnabled = isEnabled
        slider.isUserInteractionEnabled = isEnabled
//        slider.setMinimumTrackImage(currentMinimumTrackImage, for: .normal)
//        slider.setMaximumTrackImage(currentMaximumTrackImage, for: .normal)
        slider.setThumbImage(currentThumbImage, for: .normal)
        slider.minimumTrackTintColor = minimumTrackTintColor
        slider.maximumTrackTintColor = maximumTrackTintColor
//        slider.thumbTintColor = thumbTintColor
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
    }
    
    func updateMinValueLabel() {
        minimumValueLabel.font = rangeLabelFont
        minimumValueLabel.textColor = rangeLabelColor
        minimumValueLabel.text = formattedValue(minimumValue)
    }
    
    func updateMaxValueLabel() {
        maximumValueLabel.font = rangeLabelFont
        maximumValueLabel.textColor = rangeLabelColor
        maximumValueLabel.text = formattedValue(maximumValue)
    }
    
    func updateRangeLabels() {
        updateMinValueLabel()
        updateMaxValueLabel()
    }
    
    // Constraints    
    func setupBaseContainerConstraints() {
        baseContainer.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(66)
        }
    }
    
    func setupSliderConstraints() {
        slider.snp.makeConstraints { make in
            make.top.equalTo(baseContainer.snp.bottom).offset(-8)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(18)
        }
    }
    
    func setupMinValueLabelConstraints() {
        minimumValueLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(1)
            make.left.equalTo(slider.snp.left)
        }
    }
    
    func setupMaxValueLabelConstraints() {
        maximumValueLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(1)
            make.right.equalTo(slider.snp.right)
        }
    }
    
    override func setupErrorLabelConstraints() {
        errorLabel.snp.makeConstraints { make in
            make.left.equalTo(slider.snp.left)
            make.right.equalTo(slider.snp.right)
            make.top.equalTo(minimumValueLabel.snp.bottom).offset(1)
            make.bottom.greaterThanOrEqualToSuperview()
        }
    }
    
    // Actions
    
    @objc private func didSliderChangeValue(_ sender: Any) {
        value = slider.value
        didChange?(value)
    }
}
