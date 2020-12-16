//
//  FormSubmitViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class FormSubmitViewController : FormEditViewController {
    @IBOutlet weak var saveButton: HighlightButton?
    var saveButtonTitle: String { return NSLocalizedString("Save", comment: "Save") }
    
    var canSave: Bool { return true }
    
    override func setupUI() {
        super.setupUI()
        saveButton?.setTitle(saveButtonTitle, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc func keyboardWillAppear() {
        guard let saveButton = saveButton else { return }
        saveButton.isEnabled = false
        UIView.animate(withDuration: 0.3) {
            saveButton.alpha = 0.0
        }
    }

    @objc func keyboardWillDisappear(notification: NSNotification) {
        guard let saveButton = saveButton else { return }
        saveButton.isEnabled = true
        guard let info = notification.userInfo else {
            saveButton.alpha = 1.0
            return
        }
        if let durationNumber = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
            
            UIView.animate(withDuration: 0.3, delay: durationNumber.doubleValue, options: .curveEaseInOut, animations: {
                saveButton.alpha = 1.0
            }, completion: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        guard canSave else { return }
        save()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        close()
    }
    
    override func operationStarted() {
        super.operationStarted()
        saveButton?.isEnabled = false
    }
    
    override func operationFinished() {
        super.operationFinished()
        self.saveButton?.isEnabled = true
    }
}
