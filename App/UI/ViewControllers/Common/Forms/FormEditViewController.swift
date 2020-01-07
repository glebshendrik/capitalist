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
        return UIColor.by(.black2)
    }
    
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    var factory: UIFactoryProtocol!
    var tableViewController: FormFieldsTableViewController!
    
    var shouldLoadData: Bool { return false }
    var formTitle: String { return "" }
    var loadErrorMessage: String? { return nil }
    var saveErrorMessage: String { return "Ошибка сохранения" }
    var removeErrorMessage: String { return "Ошибка удаления" }
    
    lazy var formFields: [String : FormField] = {
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
            let viewController = segue.destination as? FormFieldsTableViewController {
            tableViewController = viewController
            setup(tableController: tableViewController)
        }
    }
    
    func registerFormFields() -> [String : FormField] {
        return [:]
    }
    
    func loadData() {
        operationStarted()
        
        _ = firstly {
                loadDataPromise()
            }.catch { _ in
                if let loadErrorMessage = self.loadErrorMessage {
                    self.messagePresenterManager.show(navBarMessage: loadErrorMessage, theme: .error)
                }
            }
            .finally {
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
        }.catch { error in
            switch error {
            case ValidationError.invalid(let errors):
                self.add(errors: errors)
            case APIRequestError.unprocessedEntity(let errors):
                self.add(errors: errors)
            default:
                self.handleSave(error)
            }
        }.finally {
            self.operationFinished()
        }
    }
    
    func handleSave(_ error: Error) {
        self.messagePresenterManager.show(navBarMessage: self.saveErrorMessage,
                                          theme: .error)
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
            self.close() {
                self.didRemove()
            }
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
    
    func close(completion: (() -> Void)? = nil) {
        navigationController?.dismiss(animated: true, completion: completion)
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
        setupNavigationBarAppearance()
        navigationItem.title = formTitle
    }
    
    func updateUI() {
        
    }
    
    func updateNavBarUI() {
        navigationController?.navigationBar.barTintColor = UIColor.by(.black2)        
    }
    
    func setup(tableController: FormFieldsTableViewController) {
        
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
        close()
    }
    
    func didRemove() {
        
    }
}
