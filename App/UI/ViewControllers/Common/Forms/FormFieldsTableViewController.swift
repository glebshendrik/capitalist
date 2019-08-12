//
//  FloatingFieldsStaticTableViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import StaticTableViewController
import IQKeyboardManager

class FormFieldsTableViewController : StaticTableViewController, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var activityIndicatorCell: UITableViewCell?
    @IBOutlet weak var loaderImageView: UIImageView?
    private var returnKeyHandler: IQKeyboardReturnKeyHandler!
    
    var lastResponder: UIView? { return responders.last }
    var responders: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()        
    }
    
    func showActivityIndicator() {
        guard let activityIndicatorCell = activityIndicatorCell else { return }
        set(cell: activityIndicatorCell, hidden: false, animated: false)
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
        deleteAnimation = .top
        tableView.allowsSelection = false
        returnKeyHandler = IQKeyboardReturnKeyHandler(viewController: self)
        returnKeyHandler.delegate = self
        returnKeyHandler.lastTextFieldReturnKeyType = .done
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
        
    }
    
}

class SaveAccessoryFormFieldsTableViewController : FormFieldsTableViewController {
    var saveButton: KeyboardHighlightButton = KeyboardHighlightButton()
    var saveButtonTitle: String { return "Save" }
    
    override func setupUI() {
        super.setupUI()
        setupSaveButton()
    }
    
    func setupSaveButton() {
        saveButton.setTitle(saveButtonTitle, for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "Rubik-Regular", size: 14)!
        saveButton.titleLabel?.textColor = UIColor.by(.textFFFFFF)
        saveButton.backgroundColor = UIColor.by(.blue6A92FA)
        saveButton.backgroundColorForNormal = UIColor.by(.blue6A92FA)
        saveButton.backgroundColorForHighlighted = UIColor.by(.blue5B86F7)        
        saveButton.addTarget(self, action: #selector(didTapSaveButton(_:)), for: .touchUpInside)
    }
    
    @objc private func didTapSaveButton(_ sender: UIButton) {
        didTapSave()
    }
    
    func setupAsEmail(_ field: FormTextField) {
        field.textField.textContentType = UITextContentType.emailAddress
        field.textField.keyboardType = UIKeyboardType.emailAddress
        field.textField.autocapitalizationType = UITextAutocapitalizationType.none
        field.textField.autocorrectionType = UITextAutocorrectionType.no
        field.textField.inputAccessoryView = saveButton
    }
    
    func setupAsSecure(_ field: FormTextField) {
        field.textField.isSecureTextEntry = true
        field.textField.textContentType = UITextContentType.password
        field.textField.inputAccessoryView = saveButton
    }    
}
