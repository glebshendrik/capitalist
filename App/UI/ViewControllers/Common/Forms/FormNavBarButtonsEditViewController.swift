//
//  FormNavBarButtonsEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 31/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class FormNavBarButtonsEditViewController : FormSubmitViewController {
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    override func operationStarted() {
        super.operationStarted()
        saveBarButton.isEnabled = false
    }
    
    override func operationFinished() {
        super.operationFinished()
        self.saveBarButton.isEnabled = true
    }
}
