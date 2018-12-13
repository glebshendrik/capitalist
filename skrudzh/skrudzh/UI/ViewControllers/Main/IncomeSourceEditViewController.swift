//
//  IncomeSourceEditViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 13/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import StaticDataTableViewController

class IncomeSourceEditViewController : StaticDataTableViewController, NavigationBarColorable {
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor
    
    @IBOutlet weak var incomeSourceNameTextField: UITextField!
    @IBOutlet weak var activityIndicatorCell: UITableViewCell!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.mainNavBarColor
        setActivityIndicator(hidden: true, animated: false)
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        close()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        close()
    }
    
    private func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension IncomeSourceEditViewController {
    private func setupUI() {
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func setActivityIndicator(hidden: Bool, animated: Bool = true) {
        cell(activityIndicatorCell, setHidden: hidden)
        reloadData(animated: animated, insert: .top, reload: .fade, delete: .bottom)
    }
}
