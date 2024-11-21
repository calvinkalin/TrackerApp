//
//  TabBarController.swift
//  Tracker
//
//  Created by Ilya Kalin on 22.08.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBarItems()
        view.backgroundColor = .white
        
    }
    
    fileprivate func extractedFunc(_ trackerViewController: TrackerViewController) {
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Trackers"),
            selectedImage: nil
        )
    }
    
    private func setUpBarItems() {
        let trackerViewController = TrackerViewController()
        extractedFunc(trackerViewController)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
        title: "Статистика",
        image: UIImage(named: "Statistics"),
        selectedImage: nil
        )
        
        let navigationViewController = UINavigationController(rootViewController: trackerViewController)
        
        self.viewControllers = [navigationViewController, statisticsViewController]
    }
}
