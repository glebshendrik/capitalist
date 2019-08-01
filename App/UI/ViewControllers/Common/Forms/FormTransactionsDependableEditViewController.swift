//
//  FormTransactionsDependableEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 31/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class FormTransactionsDependableEditViewController : FormNavBarButtonsEditViewController {
    var deleteTransactions: Bool = false
    
    var removeQuestionMessage: String { return "Remove?" }
    
    func didTapRemoveButton() {
        let alertController = UIAlertController(title: removeQuestionMessage,
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addAction(title: "Удалить",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: { _ in
                                    self.deleteTransactions = false
                                    self.remove()
        })
        
        alertController.addAction(title: "Удалить вместе с транзакциями",
                                  style: .destructive,
                                  isEnabled: true,
                                  handler: { _ in
                                    self.deleteTransactions = true
                                    self.remove()
        })
        
        alertController.addAction(title: "Отмена",
                                  style: .cancel,
                                  isEnabled: true,
                                  handler: nil)
        
        present(alertController, animated: true)
    }
}