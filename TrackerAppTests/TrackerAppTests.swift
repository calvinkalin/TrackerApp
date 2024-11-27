//
//  TrackerAppTests.swift
//  TrackerAppTests
//
//  Created by Ilya Kalin on 27.11.2024.
//

import XCTest
import SnapshotTesting
@testable import TrackerApp

final class TrackerTests: XCTestCase {

    func testTrackerViewControllerLight() {
        let vc = TrackerViewController()
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackerViewControllerDark() {
        let vc = TrackerViewController()
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
