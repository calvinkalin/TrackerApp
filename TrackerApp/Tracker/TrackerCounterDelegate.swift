//
//  TrackerCounterDelegate.swift
//  Tracker
//
//  Created by Ilya Kalin on 18.10.2024.
//

import Foundation


protocol TrackerCounterDelegate: AnyObject {
    func increaseTrackerCounter(id: UUID, date: Date)
    func decreaseTrackerCounter(id: UUID, date: Date)
    func checkIfTrackerWasCompletedAtCurrentDay(id: UUID, date: Date) -> Bool
    func calculateTimesTrackerWasCompleted(id: UUID) -> Int
}
