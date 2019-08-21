//
//  OnboardingPagesViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol OnboardingPagesViewControllerDelegate {
    func didPresentPage()
}

class OnboardingPagesViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ApplicationRouterDependantProtocol {
    
    var router: ApplicationRouterProtocol!
    var onboardingDelegate: OnboardingPagesViewControllerDelegate? = nil
    
    var isLastPageShown: Bool {
        let page = viewControllers?.first
        return presentationIndex(of: page) == (pages.count - 1)
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        
        self.view.backgroundColor = UIColor.by(.dark2A314B)
        if let firstPage = pages.first {
            show(viewController: firstPage)
        }
        
        setupUI()
    }
    
    func showNextPage() {
        guard !isLastPageShown else {
            finishOnboarding()
            return
        }
        guard let current = viewControllers?.first else { return }
        showNext(after: current)
    }
    
    func showNext(after viewController: UIViewController) {
        if let nextPage = pageViewController(self, viewControllerAfter: viewController) {
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
        return presentationIndex(of: viewControllers?.first)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        onboardingDelegate?.didPresentPage()
    }
    
    private func show(viewController: UIViewController) {
        setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
        onboardingDelegate?.didPresentPage()
    }
    
    private func presentationIndex(of viewController: UIViewController?) -> Int {
        guard   let viewController = viewController,
            let firstViewControllerIndex = pages.index(of: viewController) else {
                
                return 0
        }
        return firstViewControllerIndex
    }
    
    private func setupUI() {
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [type(of: self)])
        pageControl.currentPageIndicatorTintColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
        pageControl.pageIndicatorTintColor = UIColor(red: 0.89, green: 0.91, blue: 0.97, alpha: 1)
        pageControl.backgroundColor = UIColor.clear
    }
}
