//
//  DatePickerViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 06/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate {
    func didSelect(date: Date?)
}

protocol DatePickerViewControllerInputProtocol {
    func set(date: Date?)
    func set(delegate: DatePickerViewControllerDelegate?)
}

class DatePickerViewController : UIViewController, DatePickerViewControllerInputProtocol {
    
    private var delegate: DatePickerViewControllerDelegate? = nil
    
    let invisibleTextField: UITextField = UITextField(frame: CGRect.zero)
    
    lazy var backgroundView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.maximumDate = Date()
        picker.datePickerMode = .dateAndTime
        picker.addTarget(self, action: #selector(self.didChangeDate(_:)), for: UIControl.Event.valueChanged)
        return picker
    }()
    
    lazy var toolbarTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Roboto-Medium", size: 18)
        label.autoresizingMask = .flexibleWidth
        label.width = 0.0
        label.textColor = UIColor.by(.white100)
        
        return label
    }()
    
    lazy var datePickerToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.clipsToBounds = true
        toolbar.barStyle = UIBarStyle.blackOpaque
        toolbar.barTintColor = UIColor.by(.black2)
        toolbar.tintColor = UIColor.by(.white100)
        
        toolbar.setBackgroundImage(UIImage(),
                                        forToolbarPosition: .any,
                                        barMetrics: .default)
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        
        let labelButton = UIBarButtonItem(customView: toolbarTitleLabel)
        labelButton.width = 0.0
        
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "close-icon")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.didTapCloseButton(_:)))
        
        let saveButton = UIBarButtonItem(image: UIImage(named: "save-icon"), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.didTapSaveButton(_:)))
        saveButton.tintColor = UIColor.by(.blue1)
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([closeButton, flexButton, labelButton, flexButton, saveButton], animated: true)
        return toolbar
    }()
    
    lazy var toolbarContainer: UIView = {
        let view = UIView(frame: CGRect(origin: CGPoint.zero,
                                        size: CGSize(width: self.view.frame.size.width,
                                                     height: datePickerToolbar.frame.size.height + 12.0)))
        datePickerToolbar.frame = CGRect(origin: CGPoint(x: 0, y: 8.0),
                                         size: datePickerToolbar.frame.size)
        view.backgroundColor = UIColor.by(.black2)
        view.addSubview(datePickerToolbar)
        return view
    }()
    
    var isPresenting = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDateLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        focusInputView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolbarContainer.roundTopCorners(radius: 8.0)
    }
    
    func set(delegate: DatePickerViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func set(date: Date?) {
        datePicker.date = date ?? Date()
        updateDateLabel()
    }
    
    func set(date: Date?, minDate: Date?, maxDate: Date?, mode: UIDatePicker.Mode = .date) {
        datePicker.date = date ?? Date()
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.datePickerMode = mode
        updateDateLabel()
    }
    
    private func setupUI() {
        configureBackground()
        configureInputTextField()
    }
    
    private func configureBackground() {
        view.backgroundColor = .clear
        view.addSubview(backgroundView)
        
        backgroundView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didTapBackgroundView(_:))))
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView(_:))))
    }
    
    private func configureInputTextField() {
        invisibleTextField.inputView = datePicker
        invisibleTextField.inputAccessoryView = toolbarContainer
        toolbarContainer.roundTopCorners(radius: 8.0)
        view.addSubview(invisibleTextField)
    }
    
    private func focusInputView() {
        invisibleTextField.becomeFirstResponder()
    }
    
    @objc func didTapBackgroundView(_ sender: UITapGestureRecognizer) {
        close()
    }
    
    @objc func didTapCloseButton(_ sender: UIBarButtonItem) {
        close()
    }
    
    @objc func didTapSaveButton(_ sender: UIBarButtonItem) {
        delegate?.didSelect(date: datePicker.date)
        close()
    }
    
    @objc func didChangeDate(_ sender: UIDatePicker) {
        updateDateLabel()
    }
    
    private func updateDateLabel() {
        toolbarTitleLabel.text = datePicker.datePickerMode == .dateAndTime ? datePicker.date.dateTimeString(ofStyle: .short) : datePicker.date.dateString(ofStyle: .short)
        toolbarTitleLabel.sizeToFit()
        datePickerToolbar.updateConstraintsIfNeeded()
        datePickerToolbar.sizeToFit()
        
    }
    
    private func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension DatePickerViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            backgroundView.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.backgroundView.alpha = 1
            }, completion: { (finished) in
                
            })
            transitionContext.completeTransition(true)
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.backgroundView.alpha = 0
                self.invisibleTextField.resignFirstResponder()
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
