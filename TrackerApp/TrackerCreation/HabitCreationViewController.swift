//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Ilya Kalin on 23.08.2024.
//

import UIKit



class HabitCreationViewController: UIViewController {
    
    
    
    private var navigationBar: UINavigationBar?
    
    weak var configureUIDelegate: ConfigureUIForTrackerCreationProtocol?
    weak var creationDelegate: TrackerCreationDelegate?


    
    enum Section: Int, CaseIterable {
        case habitName
        case categoryAndSchedule
        case emojis
        case colors
    }
    
    private let emojis = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱",
                           "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                           "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    private let colors = [UIColor.color1, UIColor.color2, UIColor.color3, UIColor.color4, UIColor.color5, UIColor.color6, UIColor.color7, UIColor.color8, UIColor.color9, UIColor.color10, UIColor.color11, UIColor.color12, UIColor.color13, UIColor.color14, UIColor.color15, UIColor.color16, UIColor.color17, UIColor.color18]
    
    private let saveButton = UIButton()
    private let cancelButton = UIButton()
    
    private let stackView = UIStackView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let items = ["Категория", "Расписание"]
    
    var selectedWeekDays: Set<WeekDays> = [] {
        didSet {
            checkIfSaveButtonCanBePressed()
        }
    }
    
    var trackerCategory = "Важное" {
        didSet {
            checkIfSaveButtonCanBePressed()

        }
    }
    
    var trackerName: String? {
        didSet {
            checkIfSaveButtonCanBePressed()
        }
    }
    
    var selectedEmoji: String? {
        didSet {
            checkIfSaveButtonCanBePressed()
        }
    }
    
    var selectedColor: UIColor? {
        didSet {
            checkIfSaveButtonCanBePressed()
        }
    }
    
    var saveButtonCanBePressed: Bool? {
        didSet {
            switch saveButtonCanBePressed {
            case true:
                saveButton.backgroundColor = .black
                saveButton.isEnabled = true
            case false:
                saveButton.backgroundColor = .lightGray
                saveButton.isEnabled = false
            default:
                saveButton.backgroundColor = .lightGray
                saveButton.isEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupStackView()
        setupCollectionView()
        setUpNavigationBar()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func setUpNavigationBar() {
        navigationBar = navigationController?.navigationBar
        navigationBar?.isHidden = false
        navigationItem.hidesBackButton = true
        navigationItem.title = "Новая привычка"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 16, weight: .regular)]
    }
    
    private func setupStackView() {
        setupSaveButton()
        setupCancelButton()
        
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.spacing = 8
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(saveButton)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    private func setupSaveButton() {
        saveButton.setTitle("Создать", for: .normal)
        saveButton.backgroundColor = UIColor.lightGray
        saveButton.layer.cornerRadius = 16
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            saveButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.clipsToBounds = true
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.backgroundColor = UIColor.white.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func saveButtonTapped() {
        guard let name = trackerName,
              let color = selectedColor,
              let emoji = selectedEmoji else { return }
        let tracker = Tracker(
            name: name,
            color: color,
            emoji: emoji,
            schedule: selectedWeekDays,
            state: .Habit
        )
        print("Tracker создан: \(tracker), \(trackerCategory)")

        
        creationDelegate?.createTracker(tracker: tracker, category: trackerCategory)
        dismiss(animated: true, completion: nil)
    }
    
    
    private func setupCollectionView() {
        
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.register(HabitNameCell.self, forCellWithReuseIdentifier: HabitNameCell.cellIdentifier)
        collectionView.register(CategoryAndScheduleCell.self, forCellWithReuseIdentifier: CategoryAndScheduleCell.cellIdentifier)
        collectionView.register(EmojisCell.self, forCellWithReuseIdentifier: EmojisCell.cellIdentifier)
        collectionView.register(ColorsCell.self, forCellWithReuseIdentifier: ColorsCell.cellIdentifier)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        collectionView.allowsMultipleSelection = true

        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -16)
        ])
    }
}

extension HabitCreationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case Section.habitName.rawValue, Section.categoryAndSchedule.rawValue:
            return 1
        case Section.emojis.rawValue:
            return emojis.count
        case Section.colors.rawValue:
            return colors.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case Section.habitName.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HabitNameCell.cellIdentifier, for: indexPath) as? HabitNameCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            cell.prepareForReuse()
            return cell
        case Section.categoryAndSchedule.rawValue:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryAndScheduleCell.cellIdentifier,
                for: indexPath
            ) as? CategoryAndScheduleCell else {
                return UICollectionViewCell()
            }
            configureUIDelegate?.configureCategoryAndScheduleCell(cell: cell)
            cell.scheduleDelegate = self
            return cell
        case Section.emojis.rawValue:
            return configureEmojiCell(cellForItemAt: indexPath)
        case Section.colors.rawValue:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCell.cellIdentifier, for: indexPath) as? ColorsCell else {
                return UICollectionViewCell()
            }
            cell.prepareForReuse()
            cell.colorView.backgroundColor = colors[indexPath.row]
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let sectionHeader  = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderCollectionReusableView.identifier,
                for: indexPath
            ) as? HeaderCollectionReusableView {
                if indexPath.section == Section.emojis.rawValue {
                    sectionHeader.titleLabel.text = "Emoji"
                    return sectionHeader
                } else if indexPath.section == Section.colors.rawValue {
                    sectionHeader.titleLabel.text = "Цвет"
                    return sectionHeader
                }
            }
        }
        return UICollectionReusableView()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section{
        case Section.emojis.rawValue, Section.colors.rawValue:
            return CGSize(width: collectionView.bounds.width, height: 18)
        default:
            return CGSize(width: collectionView.bounds.width, height: 0)
        }
    }
    
    private func configureEmojiCell(cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojisCell.cellIdentifier, for: indexPath) as? EmojisCell else {
            return UICollectionViewCell()
        }
        cell.label.text = emojis[indexPath.row]
        return cell
    }
}

//MARK: - Delegate
extension HabitCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width - 16 * 2
        
        switch indexPath.section {
        case Section.habitName.rawValue:
            return CGSize(width: cellWidth, height: 75)
        case Section.categoryAndSchedule.rawValue:
            return configureUIDelegate?.calculateTableViewHeight(width: cellWidth) ?? CGSize(width: cellWidth, height: 150)
        case Section.emojis.rawValue, Section.colors.rawValue:
            let width = collectionView.frame.width - 18 * 2
            return CGSize(width: width / 6, height: width / 6)
        default:
            return CGSize(width: cellWidth, height: 75)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == Section.categoryAndSchedule.rawValue {
            return UIEdgeInsets(top: 24, left: 16, bottom: 32, right: 16)
        }
        switch section {
        case Section.categoryAndSchedule.rawValue:
            return UIEdgeInsets(top: 24, left: 16, bottom: 32, right: 16)
        case Section.emojis.rawValue, Section.colors.rawValue:
            return UIEdgeInsets(top: 24, left: 16, bottom: 40, right: 16)
        default:
            return UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 16)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({ collectionView.deselectItem(at: $0, animated: false) })
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == Section.emojis.rawValue {
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojisCell else {
                collectionView.deselectItem(at: indexPath, animated: true)
                return
            }
            guard let emoji = cell.label.text else { return }
            selectedEmoji = emoji
        } else if indexPath.section == Section.colors.rawValue {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorsCell else {
                collectionView.deselectItem(at: indexPath, animated: true)
                return
            }
            guard let color = cell.colorView.backgroundColor else { return }
            selectedColor = color
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.section == Section.emojis.rawValue {
            selectedEmoji = nil
        } else if indexPath.section == Section.colors.rawValue {
            selectedColor = nil
        }
    }
}

//MARK: - SaveNameTrackerDelegate
extension HabitCreationViewController: SaveNameTrackerDelegate {
    func textFieldWasChanged(text: String) {
        if text == "" {
            trackerName = nil
            return
        } else {
            trackerName = text
        }
    }
}

extension HabitCreationViewController: ShowScheduleDelegate {
    
    // MARK: - Public Methods
    func showShowScheduleViewController(viewController: ScheduleViewController) {
        viewController.scheduleDelegate = self
        viewController.selectedDays = selectedWeekDays
        navigationController?.pushViewController(viewController, animated: true)
    }
}

//MARK: - ScheduleProtocol
extension HabitCreationViewController: ScheduleProtocol {
    
    // MARK: - Public Methods
    func saveSelectedDays(selectedDays: Set<WeekDays>) {
        if selectedDays.isEmpty {
            selectedWeekDays = []
        } else {
            selectedWeekDays = []
            selectedDays.forEach {
                selectedWeekDays.insert($0)
            }
        }
        
        if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 1)) as? CategoryAndScheduleCell {
            cell.updateSubtitleLabel( forCellAt: IndexPath( row: 1, section: 0), text: convertSelectedDaysToString())
        }
    }
    
    private func convertSelectedDaysToString() -> String {
        let weekSet = Set(WeekDays.allCases)
        
        var scheduleSubtext = String()
        
        if selectedWeekDays == weekSet {
            scheduleSubtext = "Каждый день"
        } else if !selectedWeekDays.isEmpty {
            selectedWeekDays.sorted {
                $0.rawValue < $1.rawValue
            }.forEach { day in
                scheduleSubtext += day.shortName
                scheduleSubtext += ", "
            }
            scheduleSubtext = String(scheduleSubtext.dropLast(2))
        } else {
            return ""
        }
        return scheduleSubtext
    }
}


extension HabitCreationViewController: ConfigureUIForTrackerCreationProtocol {
   
    // MARK: - Public Methods
    func configureCategoryAndScheduleCell(cell: CategoryAndScheduleCell) {
        cell.prepareForReuse()
        cell.scheduleDelegate = self
        cell.state = .Habit
    }
    
    func calculateTableViewHeight(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: 150)
    }
    
    func checkIfSaveButtonCanBePressed() {
        if trackerName != nil,
           selectedEmoji != nil,
           selectedColor != nil,
           trackerCategory != nil,
           !selectedWeekDays.isEmpty
        {
            saveButtonCanBePressed = true
        } else {
            saveButtonCanBePressed = false
        }
    }
}
