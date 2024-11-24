//
//  CategoryStoreError.swift
//  TrackerApp
//
//  Created by Ilya Kalin on 23.11.2024.
//

import Foundation

enum CategoryStoreError: Error {
    case decodingTitleError
    case decodingTrackersError
    case addNewTrackerError
    case fetchingCategoryError
}
