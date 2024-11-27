//
//  OnboardingViewController.swift
//  TrackerApp
//
//  Created by Ilya Kalin on 25.11.2024.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    // MARK: - Public Properties
    lazy var onboardingPages: [UIViewController] = {
        let blue = OnboardingPageVC(
            text: NSLocalizedString("onboarding.first", comment: ""),
            imageTitle: "OnboardingBlue"
        )
        
        let red = OnboardingPageVC(
            text: NSLocalizedString("onboarding.second", comment: ""),
            imageTitle: "OnboardingRed"
        )
        
        return [blue, red]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = onboardingPages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - Private Properties
    private let button = UIButton(type: .custom)
    
    // MARK: - Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = onboardingPages.first {
            setViewControllers(
                [first],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
        
        setupButton()
        setupPageControl()
    }
    
    // MARK: - IBAction
    @objc
    private func didTapButton() {
        let tabBarVC = TabBarViewController()
        guard let window = UIApplication.shared.windows.first
        else {
            fatalError("Invalid Configuration")
        }
        
        tabBarVC.tabBar.alpha = 0
        UIView.transition(
            with: window,
            duration: 0.6,
            options: UIView.AnimationOptions.curveEaseOut,
            animations: {
                window.rootViewController = tabBarVC
                tabBarVC.tabBar.alpha = 1
            })
    }
    
    // MARK: - Private Methods
    private func setupButton() {
        let buttonText = NSLocalizedString("onboarding.button", comment: "")
        button.setTitle(buttonText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - DataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = onboardingPages.firstIndex(of: viewController) else {
            return nil
        }
        
        var previousIndex = viewControllerIndex - 1
        
        if previousIndex < 0 {
            previousIndex = onboardingPages.count - 1
        }
        
        return onboardingPages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = onboardingPages.firstIndex(of: viewController) else {
            return nil
        }
        
        var nextIndex = viewControllerIndex + 1
        
        if nextIndex >= onboardingPages.count  {
            nextIndex = 0
        }
        return onboardingPages[nextIndex]
    }
}

// MARK: - Delegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = onboardingPages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
