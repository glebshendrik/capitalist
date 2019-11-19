//
//  EntityInfoViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 08/11/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class EntityInfoNavigationController : UINavigationController {
    var entityInfoViewModel: EntityInfoViewModel? { return nil }
    
    var entityInfoViewController: EntityInfoViewController? {
        return viewControllers.first as? EntityInfoViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entityInfoViewController?.viewModel = entityInfoViewModel
    }
}


class EntityInfoViewController : UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: EntityInfoViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        
    }    
}

