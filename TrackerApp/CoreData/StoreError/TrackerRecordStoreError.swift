//
//  TrackerRecordStoreError.swift
//  TrackerApp
//
//  Created by Ilya Kalin on 23.11.2024.
//

import Foundation

enum TrackerRecordStoreError: Error {
    case decodingTrackerRecordIdError
    case decodingTrackerRecordDateError
    case fetchTrackerRecordError
}
