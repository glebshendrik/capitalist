//
//  ExpenseSourceSelectViewController.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwipeCellKit
import SnapKit

class ExpenseSourceSelectViewController : UIViewController, ApplicationRouterDependantProtocol {

    @IBOutlet weak var containerView: UIView!
    
    var router: ApplicationRouterProtocol!
    lazy var expenseSourcesViewController: ExpenseSourcesViewController! = {
        return router.viewController(.ExpenseSourcesViewController) as! ExpenseSourcesViewController
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        embedChildren()
        setupChildrenUI()
    }
    
    private func embedChildren() {
        addChild(expenseSourcesViewController)
        containerView.addSubview(expenseSourcesViewController.view)
        expenseSourcesViewController.view.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        expenseSourcesViewController.didMove(toParent: self)
    }
    
    private func setupChildrenUI() {
        expenseSourcesViewController.viewModel.shouldCalculateTotal = false
        expenseSourcesViewController.viewModel.isAddingAllowed = true
    }
        
    func set(delegate: ExpenseSourcesViewControllerDelegate,
             skipExpenseSourceId: Int?,
             selectionType: TransactionPart,
             currency: String?) {
        
        expenseSourcesViewController.set(delegate: delegate,
                                         skipExpenseSourceId: skipExpenseSourceId,
                                         selectionType: selectionType,
                                         currency: currency)
    }
}

