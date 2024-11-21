//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Ilya Kalin on 23.08.2024.
//

import Foundation

struct TrackerRecord {
    let id: UUID
    let date: Date
    
    init(id: UUID, date: Date) {
        self.id = id
        self.date = date
    }
}
