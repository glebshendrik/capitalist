//
//  FormEditViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import PromiseKit

class FormEditViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable, UIFactoryDependantProtocol {
        
    var navigationBarTintColor: UIColor? {
        return UIColor.by(.dark333D5B)
    }
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    var tableViewController: FloatingFieldsStaticTableViewController!
    
    var shouldLoadData: Bool { return true }
    var formTitle: String { return "" }
    var saveErrorMessage: String { return "Ошибка сохранения" }
    var removeErrorMessage: String { return "Ошибка удаления" }
    
    lazy var formFields: [String : FormTextField] = {
        return registerFormFields()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavBarUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditTableView",
            let viewController = segue.destination as? FloatingFieldsStaticTableViewController {
            tableViewController = viewController
            setup(tableController: tableViewController)
        }
    }
    
    func registerFormFields() -> [String : FormTextField] {
        return [:]
    }
    
    func loadData() {
        operationStarted()
        
        _ = firstly {
                loadDataPromise()
            }.ensure {
                self.updateUI()
                self.operationFinished()
            }
    }
    
    func save() {
        view.endEditing(true)
        operationStarted()
        
        firstly {
            savePromise()
        }.done {
            self.didSave()
            self.close()
        }.catch { error in
            switch error {
            case ValidationError.invalid(let errors):
                self.add(errors: errors)
            case APIRequestError.unprocessedEntity(let errors):
                self.add(errors: errors)
            default:
                self.messagePresenterManager.show(navBarMessage: self.saveErrorMessage,
                                                  theme: .error)
            }
        }.finally {
            self.operationFinished()
        }
    }
    
    func add(errors: [String : String]) {
        var unknownErrors = [String : String]()
        for error in errors {
            if let formField = formFields[error.key] {
                formField.addError(message: error.value)
            }
            else {
                unknownErrors[error.key] = error.value
            }
        }
        if !unknownErrors.isEmpty {
            self.messagePresenterManager.show(validationMessages: unknownErrors)
        }
    }
    
    func remove() {
        operationStarted()
        
        firstly {
            removePromise()
        }.done {
            self.didRemove()
            self.close()
        }.catch { error in
            switch error {
            case APIRequestError.unprocessedEntity(let errors):
                self.add(errors: errors)
            default:
                self.messagePresenterManager.show(navBarMessage: self.removeErrorMessage,
                                                  theme: .error)
            }
            
        }.finally {
            self.operationFinished()
        }
    }
    
    func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        setupNavigationBar()
        if shouldLoadData {
            loadData()
        }
        else {
            tableViewController?.hideActivityIndicator()
        }
    }
    
    func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = formTitle
    }
    
    func updateUI() {
        
    }
    
    func updateNavBarUI() {
        navigationController?.navigationBar.barTintColor = UIColor.by(.dark333D5B)
    }
    
    func setup(tableController: FloatingFieldsStaticTableViewController) {
        
    }
    
    // Have to override
    
    func operationStarted() {
        tableViewController?.showActivityIndicator()
    }
    
    func operationFinished() {
        tableViewController?.hideActivityIndicator()
    }
    
    func loadDataPromise() -> Promise<Void> {
        return Promise.value(())
    }
    
    func savePromise() -> Promise<Void> {
        return Promise.value(())
    }
    
    func removePromise() -> Promise<Void> {
        return Promise.value(())
    }
    
    func didSave() {
        
    }
    
    func didRemove() {
        
    }
}