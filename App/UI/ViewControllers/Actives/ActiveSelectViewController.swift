//
//  ActiveSelectViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit
import SwipeCellKit
import SnapKit

class ActiveSelectViewController : UIViewController, ApplicationRouterDependantProtocol {

    @IBOutlet weak var container: UIView!
    
    var router: ApplicationRouterProtocol!
    
    lazy var activesViewController: ActivesViewController! = {
        return router.viewController(.ActivesViewController) as! ActivesViewController
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        embedChildren()
        setupChildrenUI()
    }
    
    private func embedChildren() {
        addChild(activesViewController)
        container.addSubview(activesViewController.view)
        activesViewController.view.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        activesViewController.didMove(toParent: self)
    }
    
    private func setupChildrenUI() {
        activesViewController.viewModel.shouldCalculateTotal = false
        activesViewController.viewModel.isAddingAllowed = true
    }
        
    func set(delegate: ActivesViewControllerDelegate,
             skipActiveId: Int?,
             selectionType: TransactionPart) {
        
        activesViewController.set(delegate: delegate,
                                  skipActiveId: skipActiveId,
                                  selectionType: selectionType)
    }
}
