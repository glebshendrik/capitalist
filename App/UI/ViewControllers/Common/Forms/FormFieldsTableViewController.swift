//
//  FloatingFieldsStaticTableViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import StaticTableViewController
import IQKeyboardManager
import SnapKit

protocol FormFieldsTableViewControllerDelegate : class {
    func didTapSave()
    func didAppear()
}

class FormFieldsTableViewController : StaticTableViewController, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var activityIndicatorCell: UITableViewCell?
    @IBOutlet weak var loaderImageView: UIImageView?
    private var returnKeyHandler: IQKeyboardReturnKeyHandler!
    let didAppearOnce = Once()
    
    var lastResponder: UIView? { return responders.last }
    var responders: [UIView] = []
        
    var saveButtonTitle: String { return NSLocalizedString("Save", comment: "Save") }
    
    lazy var keyboardInputAccessoryView: UIView = {
        return createKeyboardInputAccessoryView()
    }()
    
    lazy var saveButton: KeyboardHighlightButton = {
        return createSaveButton()
    }()
        
    var formFieldsTableViewControllerDelegate: FormFieldsTableViewControllerDelegate? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppearOnce.run {
            formFieldsTableViewControllerDelegate?.didAppear()
        }
    }
    
    func showActivityIndicator() {
        guard let activityIndicatorCell = activityIndicatorCell else { return }
        set(cell: activityIndicatorCell, hidden: false, animated: false, reload: true)
        tableView.isUserInteractionEnabled = false    
    }
    
    func hideActivityIndicator(animated: Bool = false, reload: Bool = true) {
        guard let activityIndicatorCell = activityIndicatorCell else { return }
        set(cell: activityIndicatorCell, hidden: true, animated: animated, reload: reload)
        tableView.isUserInteractionEnabled = true
    }
    
    func setupUI() {
        loaderImageView?.showLoader()
        insertAnimation = .top
        deleteAnimation = .none
        reloadAnimation = .none
        tableView.allowsSelection = false
        returnKeyHandler = IQKeyboardReturnKeyHandler(viewController: self)
        returnKeyHandler.delegate = self
        returnKeyHandler.lastTextFieldReturnKeyType = .done
    }
    
    func createSaveButton() -> KeyboardHighlightButton {
        let saveButton = KeyboardHighlightButton()
        saveButton.setTitle(saveButtonTitle, for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 18)!
        saveButton.titleLabel?.textColor = UIColor.by(.white100)
        saveButton.backgroundColor = UIColor.by(.blue1)
        saveButton.backgroundColorForNormal = UIColor.by(.blue1)
        saveButton.backgroundColorForHighlighted = UIColor.by(.white40)
        saveButton.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(didTapSaveButton(_:)), for: .touchUpInside)
        return saveButton
    }
    
    func createKeyboardInputAccessoryView() -> UIView {
        let containerView = UIInputView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 64), inputViewStyle: .keyboard)
        containerView.addSubview(saveButton)
        saveButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(48)
            make.center.equalTo(containerView)
            make.left.equalTo(containerView).offset(24)
            make.right.equalTo(containerView).offset(-24)
        }
        return containerView
    }
    
    @objc private func didTapSaveButton(_ sender: UIButton) {
        didTapSave()
    }
    
    func updateTable(animated: Bool = true) {
        reloadData(animated: animated)
    }
    
    func set(cell: UITableViewCell, hidden: Bool, animated: Bool = true, reload: Bool = true) {
        set(cells: cell, hidden: hidden)
        if reload {
            updateTable(animated: animated)
        }
    }
    
    func register(responder: UIView?) {
        guard let responder = responder else { return }
        returnKeyHandler.addTextFieldView(responder)
        responders.append(responder)
        assignInputAccessoryView(responder)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == lastResponder {
            didTapSave()
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            if textView == lastResponder {
                didTapSave()
            }
        }
        return true
    }
    
    func didTapSave() {
        formFieldsTableViewControllerDelegate?.didTapSave()
    }
    
    func keyboardInputAccessoryViewFor(_ responder: UIResponder) -> UIView {
        return keyboardInputAccessoryView
    }
    
    private func assignInputAccessoryView(_ responder: UIResponder) {
        let accessory = keyboardInputAccessoryViewFor(responder)
        (responder as? UITextField)?.inputAccessoryView = accessory
        (responder as? UITextView)?.inputAccessoryView = accessory
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let moneyField = textField as? MoneyTextField, moneyField.rewriteModeEnabled {
            moneyField.text = nil
            moneyField.rewriteModeEnabled = false
        }
        return true
    }
}

class SaveAccessoryFormFieldsTableViewController : FormFieldsTableViewController {
    var saveButtonInForm: HighlightButton? { return nil }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc func keyboardWillAppear() {
        guard let saveButtonInForm = saveButtonInForm else { return }
        saveButtonInForm.isEnabled = false
        UIView.animate(withDuration: 0.3) {
            saveButtonInForm.alpha = 0.0
        }
    }

    @objc func keyboardWillDisappear() {
        guard let saveButtonInForm = saveButtonInForm else { return }
        saveButtonInForm.isEnabled = true
        UIView.animate(withDuration: 0.3) {
            saveButtonInForm.alpha = 1.0            
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupAsEmail(_ field: FormTextField) {
        field.textField.textContentType = UITextContentType.username
        field.textField.keyboardType = UIKeyboardType.emailAddress
        field.textField.autocapitalizationType = UITextAutocapitalizationType.none
        field.textField.autocorrectionType = UITextAutocorrectionType.no
    }
    
    func setupAsSecure(_ field: FormTextField) {
        field.textField.isSecureTextEntry = true
    }
    
    func setupAsPassword(_ field: FormTextField) {
        setupAsSecure(field)
        field.textField.textContentType = UITextContentType.password
    }
    
    func setupAsNewPassword(_ field: FormTextField) {
        setupAsSecure(field)
        if #available(iOS 12.0, *) {
            let passwordRuleDescription = "minlength: 6; maxlength: 20;"
            let passwordRules = UITextInputPasswordRules(descriptor: passwordRuleDescription)
            field.textField.passwordRules = passwordRules
            field.textField.textContentType = UITextContentType.newPassword
        } else {
            // Fallback on earlier versions
        }
    }
}
