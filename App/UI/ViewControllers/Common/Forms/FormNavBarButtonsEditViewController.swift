//
//  FormNavBarButtonsEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 31/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class FormNavBarButtonsEditViewController : FormEditViewController {
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        save()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        close()
    }
    
    override func operationStarted() {
        super.operationStarted()
        saveButton.isEnabled = false
    }
    
    override func operationFinished() {
        super.operationFinished()
        self.saveButton.isEnabled = true
    }
}