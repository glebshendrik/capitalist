//
//  OnboardingPagesViewController.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol OnboardingPagesViewControllerDelegate : class {
    func didPresentPage()
}

class OnboardingPagesViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ApplicationRouterDependantProtocol {
    
    var router: ApplicationRouterProtocol!
    weak var onboardingDelegate: OnboardingPagesViewControllerDelegate? = nil
    
    var isLastPageShown: Bool {
        let page = viewControllers?.first
        return presentationIndex(of: page) == (pages.count - 1)
    }
    
    var numberOfPages: Int {
        return pages.count
    }
    
    var currentPageIndex: Int {
        return presentationIndex(of: viewControllers?.first)
    }
    
    private lazy var pages: [UIViewController] = {
        return [
            router.viewController(.OnboardingPage1ViewController),
            router.viewController(.OnboardingPage2ViewController),
            router.viewController(.OnboardingPage3ViewController),
            router.viewController(.OnboardingPage4ViewController),
            router.viewController(.OnboardingPage5ViewController),
            router.viewController(.OnboardingPage6ViewController),
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
                
        self.view.backgroundColor = UIColor.by(.black2)
        if let firstPage = pages.first {
            show(viewController: firstPage)
        }
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
        _ = UIFlowManager.reach(point: .onboarding)
        router.route()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return nil }
        
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
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
            let firstViewControllerIndex = pages.firstIndex(of: viewController) else {
                
                return 0
        }
        return firstViewControllerIndex
    }
}
