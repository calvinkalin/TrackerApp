//
//  ScheduleProtocol.swift
//  Tracker
//
//  Created by Ilya Kalin on 16.11.2024.
//

import Foundation

protocol ScheduleProtocol: AnyObject {
    func saveSelectedDays(selectedDays: Set<WeekDays>)
}
