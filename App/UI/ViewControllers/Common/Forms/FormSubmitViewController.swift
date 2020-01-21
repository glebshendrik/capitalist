//
//  FormSubmitViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class FormSubmitViewController : FormEditViewController {
    @IBOutlet weak var saveButton: UIButton?
    
    @IBAction func didTapSaveButton(_ sender: Any) {
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
    
    override func close(completion: (() -> Void)? = nil) {
        navigationController?.popViewController(animated: true, completion)
    }
}
