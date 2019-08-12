//
//  FloatingFieldsStaticTableViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import StaticTableViewController

class FormFieldsTableViewController : StaticTableViewController, UITextFieldDelegate {
    @IBOutlet weak var activityIndicatorCell: UITableViewCell?
    @IBOutlet weak var loaderImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()        
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
    
    func setupUI() {
        loaderImageView?.showLoader()
        insertAnimation = .top
        deleteAnimation = .top
        tableView.allowsSelection = false
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

class SaveAccessoryFormFieldsTableViewController : FormFieldsTableViewController {
    var saveButton: KeyboardHighlightButton = KeyboardHighlightButton()
    var saveButtonTitle: String { return "Save" }
    
    override func setupUI() {
        super.setupUI()
        setupSaveButton()
    }
    
    func setupSaveButton() {
        saveButton.setTitle(saveButtonTitle, for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "Rubik-Regular", size: 14)!
        saveButton.titleLabel?.textColor = UIColor.by(.textFFFFFF)
        saveButton.backgroundColor = UIColor.by(.blue6A92FA)
        saveButton.backgroundColorForNormal = UIColor.by(.blue6A92FA)
        saveButton.backgroundColorForHighlighted = UIColor.by(.blue5B86F7)        
        saveButton.addTarget(self, action: #selector(didTapSaveButton(_:)), for: .touchUpInside)
    }
    
    @objc private func didTapSaveButton(_ sender: UIButton) {
        didTapSave()
    }
    
    func didTapSave() {
        
    }
}
