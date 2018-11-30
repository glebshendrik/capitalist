//
//  MainViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 30/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import SideMenu

class MainViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupNavigationBar()
        setupMainMenu()
    }
    
    private func setupNavigationBar() {
        let attributes = [NSAttributedString.Key.font : UIFont(name: "Rubik-Regular", size: 16)!, NSAttributedString.Key.foregroundColor : UIColor.init(red: 0.25, green: 0.27, blue: 0.38, alpha: 1)]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func setupMainMenu() {        
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.menuFadeStatusBar = false
    }
}
