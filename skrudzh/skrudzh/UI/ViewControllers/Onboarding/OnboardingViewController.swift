//
//  OnboardingViewController.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 10/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit

class OnboardingViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var router: ApplicationRouterProtocol!
    
    private lazy var pages: [UIViewController] = {
        return [
            router.viewController(.OnboardingPage1ViewController),
            router.viewController(.OnboardingPage2ViewController),
            router.viewController(.OnboardingPage3ViewController),
//            router.viewController(.OnboardingPage4ViewController),
//            router.viewController(.OnboardingPage5ViewController),
//            router.viewController(.OnboardingPage6ViewController),
//            router.viewController(.OnboardingPage7ViewController),
//            router.viewController(.OnboardingPage8ViewController)
        ]
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        
        if let firstPage = pages.first
        {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        setupPagesControl()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return pages.last }
        
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return pages.first }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = pages.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
    func setupPagesControl() {
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [type(of: self)])
        
        pageControl.currentPageIndicatorTintColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
        pageControl.pageIndicatorTintColor = UIColor(red: 0.89, green: 0.91, blue: 0.97, alpha: 1)
        pageControl.backgroundColor = UIColor.white
    }
}
