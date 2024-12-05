//
//  TrackerCreationViewController.swift
//  TrackerApp
//
//  Created by Ilya Kalin on 27.11.2024.
//

import UIKit

class TrackerCreationViewController: UIViewController {
    // MARK: - Public Properties
    weak var creationDelegate: TrackerCreationDelegate?
    weak var configureUIDelegate: ConfigureUIForTrackerCreationProtocol?
    
    var closeCreatingTrackerViewController: (() -> ())?
    
    var selectedWeekDays: Set<WeekDays> = [] {
        didSet {
            configureUIDelegate?.checkIfSaveButtonCanBePressed()
        }
    }
    
    var trackerCategory: TrackerCategory? {
        didSet {
            configureUIDelegate?.checkIfSaveButtonCanBePressed()
        }
    }
    
    var trackerName: String? {
        didSet {
            configureUIDelegate?.checkIfSaveButtonCanBePressed()
        }
    }
    
    var selectedEmoji: String? {
        didSet {
            configureUIDelegate?.checkIfSaveButtonCanBePressed()
        }
    }
    
    var selectedColor: UIColor? {
        didSet {
            configureUIDelegate?.checkIfSaveButtonCanBePressed()
        }
    }
    
    var saveButtonCanBePressed: Bool? {
        didSet {
            switch saveButtonCanBePressed {
            case true:
                saveButton.backgroundColor = dynamicColor(.black, .white)
                saveButton.setTitleColor(dynamicColor(.white, .black), for: .normal)
                saveButton.isEnabled = true
            case false:
                saveButton.backgroundColor = dynamicColor(.lightGray, .darkGray)
                saveButton.setTitleColor(dynamicColor(.darkGray, .lightGray), for: .normal)
                saveButton.isEnabled = false
            default:
                saveButton.backgroundColor = dynamicColor(.lightGray, .darkGray)
                saveButton.setTitleColor(dynamicColor(.darkGray, .lightGray), for: .normal)
                saveButton.isEnabled = false
            }
        }
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - Private Properties
    private let stackView = UIStackView()
    private let saveButton = UIButton()
    private let cancelButton = UIButton()
    private let allEmojies = Constants.allEmojies
    private let allColors = Constants.allColors
    
    // MARK: - Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        
        setupStackView()
        setupCollectionView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - IBAction
    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func cancelButtonPressed() {
        dismiss(animated: true)
        closeCreatingTrackerViewController?()
    }
    
    @objc
    func saveButtonPressed() {
        guard let name = trackerName,
              let color = selectedColor,
              let emoji = selectedEmoji,
              let categoryTitle = trackerCategory?.title
        else { return }
        let tracker = Tracker(
            name: name,
            color: color,
            emoji: emoji,
            schedule: selectedWeekDays,
            state: .habit,
            isPinned: false
        )
        
        creationDelegate?.createTracker(tracker: tracker, category: categoryTitle)
        dismiss(animated: true)
        closeCreatingTrackerViewController?()
    }
    
    // MARK: - Private Methods
    
    ///MARK: - Setup StackView And Buttons
    private func setupSaveButton() {
        saveButton.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        saveButton.titleLabel?.textColor = dynamicColor(.white, .black)
        saveButton.backgroundColor = dynamicColor(.lightGray, .darkGray)
        saveButton.layer.cornerRadius = 16
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        saveButton.accessibilityIdentifier = "saveNewTracker"
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    private func dynamicColor(_ lightModeColor: UIColor, _ darkModeColor: UIColor) -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
        }
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.clipsToBounds = true
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.backgroundColor = dynamicColor(.white, .background)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupStackView() {
        setupSaveButton()
        setupCancelButton()
        
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.spacing = 8
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.fill
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(saveButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    ///MARK: - Setup CollectionView
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(HabitNameCell.self, forCellWithReuseIdentifier: HabitNameCell.cellIdentifier)
        collectionView.register(CategoryAndScheduleCell.self, forCellWithReuseIdentifier: CategoryAndScheduleCell.cellIdentifier)
        collectionView.register(EmojisCell.self, forCellWithReuseIdentifier: EmojisCell.cellIdentifier)
        collectionView.register(ColorsCell.self, forCellWithReuseIdentifier: ColorsCell.cellIdentifier)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        collectionView.allowsMultipleSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -16)
        ])
    }
}

//MARK: DataSource
extension TrackerCreationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case Sections.name.rawValue, Sections.buttons.rawValue:
            return CellSize.one
        case Sections.emoji.rawValue:
            return allEmojies.count
        case Sections.color.rawValue:
            return allColors.count
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case Sections.name.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HabitNameCell.cellIdentifier, for: indexPath) as? HabitNameCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            cell.prepareForReuse()
            return cell
        case Sections.buttons.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryAndScheduleCell.cellIdentifier, for: indexPath) as? CategoryAndScheduleCell else {
                return UICollectionViewCell()
            }
            configureUIDelegate?.configureCategoryAndScheduleCell(cell: cell)
            return cell
        case Sections.emoji.rawValue:
            return configureEmojiCell(cellForItemAt: indexPath)
        case Sections.color.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCell.cellIdentifier, for: indexPath) as? ColorsCell else {
                return UICollectionViewCell()
            }
            cell.prepareForReuse()
            cell.setColor(with: allColors[indexPath.row])
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Sections.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let sectionHeader  = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderCollectionReusableView.identifier,
                for: indexPath
            ) as? HeaderCollectionReusableView {
                if indexPath.section == Sections.emoji.rawValue {
                    sectionHeader.titleLabel.text = NSLocalizedString("emoji", comment: "")
                    return sectionHeader
                } else if indexPath.section == Sections.color.rawValue {
                    sectionHeader.titleLabel.text = NSLocalizedString("color", comment: "")
                    return sectionHeader
                }
            }
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section{
        case Sections.emoji.rawValue, Sections.color.rawValue:
            return CGSize(width: collectionView.bounds.width, height: 18)
        default:
            return CGSize(width: collectionView.bounds.width, height: 0)
        }
    }
    
    private func configureEmojiCell(cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojisCell.cellIdentifier, for: indexPath) as? EmojisCell else {
            return UICollectionViewCell()
        }
        cell.setEmoji(with: allEmojies[indexPath.row])
        return cell
    }
}

//MARK: - Delegate
extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width - 16 * 2
        
        switch indexPath.section {
        case Sections.name.rawValue:
            return CGSize(width: cellWidth, height: 75)
        case Sections.buttons.rawValue:
            return configureUIDelegate?.calculateTableViewHeight(width: cellWidth) ?? CGSize(width: cellWidth, height: 150)
        case Sections.emoji.rawValue, Sections.color.rawValue:
            let width = collectionView.frame.width - 18 * 2
            return CGSize(width: width / 6, height: width / 6)
        default:
            return CGSize(width: cellWidth, height: 75)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == Sections.buttons.rawValue {
            return UIEdgeInsets(top: 24, left: 16, bottom: 32, right: 16)
        }
        switch section {
        case Sections.buttons.rawValue:
            return UIEdgeInsets(top: 24, left: 16, bottom: 32, right: 16)
        case Sections.emoji.rawValue, Sections.color.rawValue:
            return UIEdgeInsets(top: 24, left: 16, bottom: 40, right: 16)
        default:
            return UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 16)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({ collectionView.deselectItem(at: $0, animated: false) })
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == Sections.emoji.rawValue {
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojisCell else {
                collectionView.deselectItem(at: indexPath, animated: true)
                return
            }
            selectedEmoji = cell.getEmoji()
        } else if indexPath.section == Sections.color.rawValue {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorsCell else {
                collectionView.deselectItem(at: indexPath, animated: true)
                return
            }
            selectedColor = cell.getColor()
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.section == Sections.emoji.rawValue {
            selectedEmoji = nil
        } else if indexPath.section == Sections.color.rawValue {
            selectedColor = nil
        }
    }
}

//MARK: - SaveNameTrackerDelegate
extension TrackerCreationViewController: SaveNameTrackerDelegate {
    func textFieldWasChanged(text: String) {
        if text == "" {
            trackerName = nil
            return
        } else {
            trackerName = text
        }
    }
}

// MARK: - CategorySelectProtocol
extension TrackerCreationViewController: CategoryWasSelectedProtocol {
    func categoryWasSelected(category: TrackerCategory) {
        trackerCategory = category
        
        if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 1)) as? CategoryAndScheduleCell  {
            cell.updateSubtitleLabel(
                forCellAt: IndexPath(row: 0, section: 0),
                text: trackerCategory?.title ?? "")
        }
    }
}

//MARK: - ShowCategoriesDelegate
extension TrackerCreationViewController: ShowCategoriesDelegate {
    func showCategoriesViewController(viewController: CategoryViewController) {
        
        if let trackerCategory = trackerCategory {
            viewController.categoriesViewModel.selectedCategory = CategoryViewModel(title: trackerCategory.title, trackers: trackerCategory.trackers)
        }
        viewController.categoriesViewModel.categoryWasSelectedDelegate = self
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
