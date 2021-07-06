//
//  OCPageViewController.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-08-04.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - OCPageViewControllerDelegate

protocol OCPageViewControllerDelegate: AnyObject {
    
    func didChangeViewController(to index: Int)
}

// MARK: - OCPageViewController

class OCPageViewController: UIPageViewController {
    
    // MARK: Lifecycle

    init(orderedViewControllers: [UIViewController]) {
        self.orderedViewControllers = orderedViewControllers
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var pageViewDelegate: OCPageViewControllerDelegate?
    
    let orderedViewControllers: [UIViewController]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true)
        }
    }
    
    // MARK: Private
    
    private var currentIndex = 0
    
    func setVisibleViewController(index: Int) {
        setViewControllers(
            [orderedViewControllers[index]],
            direction: index < currentIndex ? .reverse : .forward,
            animated: true)
        
        currentIndex = index
    }
}

// MARK: UIPageViewControllerDelegate

extension OCPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool)
    {
        guard completed,
            let viewController = viewControllers?.first,
            let index = orderedViewControllers.firstIndex(of: viewController) else
        {
            return
        }
        
        currentIndex = index
        pageViewDelegate?.didChangeViewController(to: index)
    }
}

// MARK: UIPageViewControllerDataSource

extension OCPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 && orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex && orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}
