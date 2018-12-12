//
//  MainViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import SideMenu

class MainViewController : UIViewController, UIMessagePresenterManagerDependantProtocol, NavigationBarColorable {
    
    var navigationBarTintColor: UIColor? = UIColor.mainNavBarColor
    
    var viewModel: MainViewModel!
    var messagePresenterManager: UIMessagePresenterManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print("Did run before \(className): \(didRunBefore)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.mainNavBarColor
    }
    
    private func setupUI() {
        setupNavigationBar()
        setupMainMenu()
    }
    
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!,
                          NSAttributedString.Key.foregroundColor : UIColor.init(red: 48 / 255.0,
                                                                                green: 53 / 255.0,
                                                                                blue: 79 / 255.0,
                                                                                alpha: 1)]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        // 64 69 97
    }
    
    private func setupMainMenu() {        
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.menuFadeStatusBar = false
    }
}
