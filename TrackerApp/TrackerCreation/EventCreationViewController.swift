//
//  EventCreationViewController.swift
//  TrackerApp
//
//  Created by Ilya Kalin on 27.11.2024.
//

import UIKit

final class EventCreationViewController: TrackerCreationViewController {
    // MARK: - Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        
        
        configureUIDelegate = self
        configureUIDelegate?.setupBackground()
    }
    
    // MARK: - IBAction
    @objc
    override func saveButtonPressed() {
        guard let name = trackerName,
              let color = selectedColor,
              let emoji = selectedEmoji,
              let categoryTitle = trackerCategory?.title
        else { return }
        let week = WeekDays.allCases
        let weekSet = Set(week)
        let tracker = Tracker(
            name: name,
            color: color,
            emoji: emoji,
            schedule: weekSet,
            state: .event,
            isPinned: false
        )
        
        creationDelegate?.createTracker(tracker: tracker, category: categoryTitle)
        dismiss(animated: true)
    }
}

//MARK: - ConfigureUIForTrackerCreationProtocol
extension EventCreationViewController: ConfigureUIForTrackerCreationProtocol {
    
    // MARK: - Public Methods
    func configureCategoryAndScheduleCell(cell: CategoryAndScheduleCell) {
        cell.prepareForReuse()
        cell.categoriesDelegate = self
        cell.state = .event
    }
    
    func setupBackground() {
        self.title = NSLocalizedString("event.new", comment: "")
        view.backgroundColor = .background
        navigationItem.hidesBackButton = true
    }
    
    func calculateTableViewHeight(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: 75)
    }
    
    func checkIfSaveButtonCanBePressed() {
        if trackerName != nil,
           selectedEmoji != nil,
           selectedColor != nil,
           trackerCategory != nil
        {
            saveButtonCanBePressed = true
        } else {
            saveButtonCanBePressed = false
        }
    }
}
