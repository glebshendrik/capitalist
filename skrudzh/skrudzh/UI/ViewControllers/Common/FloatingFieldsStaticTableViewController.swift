//
//  FloatingFieldsStaticTableViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import StaticTableViewController

class FloatingFieldsStaticTableViewController : StaticTableViewController, UITextFieldDelegate {
    @IBOutlet weak var activityIndicatorCell: UITableViewCell?
    @IBOutlet weak var loaderImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loaderImageView?.showLoader()
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let floatingLabelTextField = textField as? FloatingTextField {
            floatingLabelTextField.updateAppearance()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let floatingLabelTextField = textField as? FloatingTextField {
            floatingLabelTextField.updateAppearance()
        }
    }
    
    private func setupUI() {
        insertAnimation = .top
        deleteAnimation = .bottom
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
}
