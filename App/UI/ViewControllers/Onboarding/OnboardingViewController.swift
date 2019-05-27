//
//  OnboardingViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

class OnboardingViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var router: ApplicationRouterProtocol!
    
    private lazy var pages: [UIViewController] = {
        return [
            router.viewController(.OnboardingPage1ViewController),
            router.viewController(.OnboardingPage2ViewController),
            router.viewController(.OnboardingPage3ViewController),
            router.viewController(.OnboardingPage4ViewController),
            router.viewController(.OnboardingPage5ViewController),
            router.viewController(.OnboardingPage6ViewController),
            router.viewController(.OnboardingPage7ViewController),
            router.viewController(.OnboardingPage8ViewController)
        ]
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        
        if let firstPage = pages.first {
            show(viewController: firstPage)
        }
        
        setupUI()
    }
    
    func showNext(after viewController: UIViewController) {
        if let nextPage = pageViewController(self, viewControllerAfter: viewController) {
            updatePageControlBackground(to: nextPage)
            show(viewController: nextPage)
        }
    }
    
    func finishOnboarding() {
        router.route()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return nil }
        
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return presentationIndex(of: viewControllers)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        updatePageControlBackground(to: pendingViewControllers.first)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        updatePageControlBackground(to: viewControllers?.first)
    }
    
    private func show(viewController: UIViewController) {
        setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
    }
    
    private func presentationIndex(of pendingViewControllers: [UIViewController]?) -> Int {
        guard   let firstViewController = pendingViewControllers?.first,
                let firstViewControllerIndex = pages.index(of: firstViewController) else {
    
            return 0
        }
    
        return firstViewControllerIndex
    }
    
    private func updatePageControlBackground(to viewController: UIViewController?) {
        if let backgroundColor = viewController?.view.backgroundColor {
            view.backgroundColor = backgroundColor
        }
        else {
            view.backgroundColor = .white
        }
    }
    
    private func setupUI() {
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [type(of: self)])
        pageControl.currentPageIndicatorTintColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
        pageControl.pageIndicatorTintColor = UIColor(red: 0.89, green: 0.91, blue: 0.97, alpha: 1)
        pageControl.backgroundColor = UIColor.clear
        view.backgroundColor = .white
    }
}
