//
//  TrackerCellInfo.swift
//  Tracker
//
//  Created by Ilya Kalin on 18.10.2024.
//

import UIKit

struct TrackerInfoCell {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let daysCount: Int
    let currentDay: Date
    let state: State
}
