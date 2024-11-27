//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Ilya Kalin on 17.10.2024.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    // MARK: - Public Properties
    static let identifier = "TrackerCell"
    
    weak var counterDelegate: TrackerCounterDelegate?
    
    var deleteTrackerHandler: ((Tracker) -> ())?
    var pinTrackerHandler: ((Tracker) -> ())?
    var editTrackerHandler: ((TrackerInfoCell) -> ())?
    
    var color: UIColor?
    
    var isPinned: Bool = false {
        didSet {
            if (isPinned) {
                pinImageView.isHidden = false
            } else {
                pinImageView.isHidden = true
            }
            
        }
    }
    
    var daysCount: Int = 0 {
        didSet {
            updateDaysCountLabel()
        }
    }
    
    var trackerInfo: TrackerInfoCell?
    {
        didSet {
            titleLabel.text = trackerInfo?.name
            emojiLabel.text = trackerInfo?.emoji
            card.backgroundColor = trackerInfo?.color
            
            daysCount = trackerInfo?.daysCount ?? daysCount
            color = trackerInfo?.color
            isPinned = trackerInfo?.isPinned ?? false
            updateAddButton()
        }
    }
    
    // MARK: - Private Properties
    private let analyticsService = AnalyticsService()
    
    private let addButton = UIButton(type: .custom)
    private let card = UIView()
    private let circle = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let pinImageView = UIImageView()
    private let daysCountLabel = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(card)
        setupCard()
        
        card.addSubview(circle)
        setupCircle()
        
        setupEmojiLabel()
        setupPinImageView()
        setupTitle()
        setupAddButton()
        setupDaysCountLabel()
        
        contentView.layer.masksToBounds = true
        
        let contextMenu = UIContextMenuInteraction(delegate: self)
        
        card.addInteraction(contextMenu)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - IBAction
    @objc
    func buttonClicked() {
        analyticsService.report(event: .click, params: ["screen" : "Main", "item" : "track"])
        
        if !checkIfTrackerWasCompleted() {
            guard let id = trackerInfo?.id,
                  let currentDay = trackerInfo?.currentDay,
                  let state = trackerInfo?.state else { return }
            if currentDay > Date() { return }
            
            let doneImage = UIImage(named: "DoneQM")?.withRenderingMode(.alwaysTemplate)
            addButton.setImage(doneImage, for: .normal)
            addButton.tintColor = dynamicColor(.white, .black)
            addButton.backgroundColor = color?.withAlphaComponent(0.3)
            
            counterDelegate?.increaseTrackerCounter(id: id, date: currentDay)
            daysCount = counterDelegate?.calculateTimesTrackerWasCompleted(id: id) ?? daysCount
        } else {
            let plusImage = UIImage(named: "Plus")?.withRenderingMode(.alwaysTemplate)
            addButton.setImage(plusImage, for: .normal)
            addButton.tintColor = dynamicColor(.white, .black)
            addButton.backgroundColor = color
            
            guard let id = trackerInfo?.id,
                  let currentDay = trackerInfo?.currentDay else { return }
            
            counterDelegate?.decreaseTrackerCounter(id: id, date: currentDay)
            daysCount = counterDelegate?.calculateTimesTrackerWasCompleted(id: id) ?? daysCount
        }
    }
    
    private func dynamicColor(_ lightModeColor: UIColor, _ darkModeColor: UIColor) -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
        }
    }
    
    // MARK: - Private Methods
    
    ///MARK: - Check status
    private func checkIfTrackerWasCompleted() -> Bool {
        guard let id = trackerInfo?.id,
              let currentDay = trackerInfo?.currentDay,
              let delegate = counterDelegate else {
            return false
        }
        return delegate.checkIfTrackerWasCompletedAtCurrentDay(id: id, date: currentDay)
    }
    
    private func updateDaysCountLabel() {
        let daysRemaining = daysCount
        let tasksString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of remaining days"),
            daysRemaining
        )
        daysCountLabel.text = tasksString
    }
    
    private func updateAddButton() {
        if checkIfTrackerWasCompleted() {
            let doneImage = UIImage(named: "DoneQM")?.withRenderingMode(.alwaysTemplate)
            addButton.setImage(doneImage, for: .normal)
            addButton.tintColor = dynamicColor(.white, .black)
            addButton.backgroundColor = color?.withAlphaComponent(0.3)
        } else {
            let plusImage = UIImage(named: "Plus")?.withRenderingMode(.alwaysTemplate)
            addButton.setImage(plusImage, for: .normal)
            addButton.tintColor = dynamicColor(.white, .black)
            addButton.backgroundColor = color
        }
        
        addButton.layer.cornerRadius = 16
    }
    
    ///MARK: - Setup UI
    private func setupCard() {
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = true
        card.accessibilityIdentifier = "trackerBackground"
        card.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 90),
            card.widthAnchor.constraint(equalToConstant: contentView.frame.width)
        ])
    }
    
    private func setupCircle() {
        circle.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        circle.layer.cornerRadius = 12
        circle.layer.masksToBounds = true
        circle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            circle.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            circle.widthAnchor.constraint(equalToConstant: 24),
            circle.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupEmojiLabel() {
        emojiLabel.font = UIFont.systemFont(ofSize: 12)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor)
        ])
    }
    
    private func setupPinImageView() {
        let image = UIImage(named: "Pin")
        pinImageView.image = image
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(pinImageView)
        
        NSLayoutConstraint.activate([
            pinImageView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            pinImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12)
        ])
    }
    
    private func setupTitle() {
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width - 12 * 2),
            titleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12)
        ])
    }
    
    private func setupDaysCountLabel() {
        contentView.addSubview(daysCountLabel)
        daysCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        updateDaysCountLabel()
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            daysCountLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8)
        ])
    }
    
    private func setupAddButton() {
        contentView.addSubview(addButton)
        updateAddButton()
        addButton.addTarget(
            self,
            action: #selector(buttonClicked),
            for: .touchUpInside
        )
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
}

//MARK: - UIContextMenuInteractionDelegate
extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let trackerInfo = trackerInfo else {
            return nil
        }
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                
                let tracker = Tracker(
                    id: trackerInfo.id,
                    name: trackerInfo.name,
                    color: trackerInfo.color,
                    emoji: trackerInfo.emoji,
                    schedule: trackerInfo.schedule,
                    state: trackerInfo.state,
                    isPinned: self.isPinned )
                
                let pinTittle = self.isPinned ? "unpin" : "pin"
                
                let pinAction = UIAction(title: NSLocalizedString(pinTittle, comment: "")) { [weak self] _ in
                    self?.pinTrackerHandler?(tracker)
                }
                
                let editAction = UIAction(title: NSLocalizedString("edit", comment: "")) { [weak self] _ in
                    self?.editTrackerHandler?(trackerInfo)
                }
                
                let deleteAction = UIAction(title: NSLocalizedString("delete", comment: ""), attributes: .destructive) { [weak self] _ in
                    self?.deleteTrackerHandler?(tracker)
                }
                
                deleteAction.accessibilityIdentifier = "deleteTracker"
                
                return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
            }
        )
    }
}
