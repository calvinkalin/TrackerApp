//
//  TrackerCreationDelegete.swift
//  Tracker
//
//  Created by Ilya Kalin on 16.11.2024.
//

import Foundation

protocol TrackerCreationDelegate: AnyObject {
    func createTracker(tracker: Tracker, category: String)
}
