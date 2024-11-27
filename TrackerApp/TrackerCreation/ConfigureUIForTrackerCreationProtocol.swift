//
//  ConfigureUIForTrackerCreationProtocol.swift
//  Tracker
//
//  Created by Ilya Kalin on 16.11.2024.
//

import Foundation

protocol ConfigureUIForTrackerCreationProtocol: AnyObject {
    func configureCategoryAndScheduleCell(cell: CategoryAndScheduleCell)
    func calculateTableViewHeight(width: CGFloat) -> CGSize
    func checkIfSaveButtonCanBePressed()
    func setupBackground()
}
