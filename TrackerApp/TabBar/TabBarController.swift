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
    
    private func extractedFunc(_ trackerViewController: TrackerViewController) {
        trackerViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers", comment: ""),
            image: UIImage(named: "Trackers"),
            selectedImage: nil
        )
    }
    
    private func setUpBarItems() {
        let trackerViewController = TrackerViewController()
        extractedFunc(trackerViewController)
        
        let trackersNavViewController = UINavigationController(rootViewController: trackerViewController)
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
        title: NSLocalizedString("statistics", comment: ""),
        image: UIImage(named: "Statistics"),
        selectedImage: nil
        )
        
        let statisticsNavViewController = UINavigationController(rootViewController: statisticsViewController)
        
        self.viewControllers = [trackersNavViewController, statisticsNavViewController]
    }
}
