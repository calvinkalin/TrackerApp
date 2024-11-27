//
//  ViewController.swift
//  Tracker
//
//  Created by Ilya Kalin on 22.08.2024.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - Public Properties
    lazy var currentCategories: [TrackerCategory] = {
        filterCategoriesToShow()
    }()
    
    var categories: [TrackerCategory] = []
    var currentDate = Date()
    var completedTrackers: [TrackerRecord] = []
    
    var trackerStore: TrackerStore!
    var trackerCategoryStore: TrackerCategoryStore!
    var trackerRecordStore: TrackerRecordStore!
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - Private Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private let questionTextLabel = UILabel()
    private var navigationBar: UINavigationBar?
    private var datePicker = UIDatePicker()
    
    // MARK: - Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return
            assertionFailure("Не удалось получить AppDelegate")
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        trackerStore = TrackerStore(context: context)
        trackerCategoryStore = TrackerCategoryStore(context: context)
        trackerRecordStore = TrackerRecordStore(context: context)
        
        setupCollectionView()
        setUpNavigationBar()
        
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
                
        categories = trackerCategoryStore.categories
        completedTrackers = trackerRecordStore.completedTrackers
        updateCollectionAccordingToDate()
    }
    
    // MARK: - IBAction
    @objc
    func didTapAddTrackerButton() {
        let createTrackerViewController = TrackerCreationViewController()
        createTrackerViewController.delegate = self
        let createTracker = UINavigationController(rootViewController: createTrackerViewController)
        navigationController?.present(createTracker, animated: true)
    }
    
    @objc
    func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        currentDate = selectedDate
        updateCollectionAccordingToDate()
    }
    
    // MARK: - Private Methods
    
    private func createNewCategory(categoryName: String) {
        do {
            try trackerCategoryStore.addNewCategory(name: categoryName)
        } catch {
            print("Failed to add new category: \(error.localizedDescription)")
        }
    }
    
    ///MARK: - Setup CollectionView
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.cellIdentifier
        )
        collectionView.register(
            HeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderCollectionReusableView.identifier
        )
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func showPlaceHolder() {
        let backgroundView = PlaceHolderView(frame: collectionView.frame)
        backgroundView.setupNoTrackersState()
        collectionView.backgroundView = backgroundView
    }
    
    ///MARK: - Setup NavigationBar
    private func setUpNavigationBar() {
        navigationBar = navigationController?.navigationBar
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let buttonImage = UIImage(named: "Plus")
        guard let buttonImage else { return }
        let plusButton = UIBarButtonItem(
            image: buttonImage,
            style: .plain,
            target: self,
            action: #selector(didTapAddTrackerButton)
        )
        plusButton.tintColor = .black
        navigationBar?.topItem?.leftBarButtonItem = plusButton
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged(_:)),
            for: .valueChanged
        )
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func filterCategoriesToShow() -> [TrackerCategory] {
        currentCategories = []
        let weekdayInt = Calendar.current.component(.weekday, from: currentDate)
        guard let day = (weekdayInt == 1) ?  WeekDays(rawValue: 7) : WeekDays(rawValue: weekdayInt - 1) else { return [] }
        
        categories.forEach { category in
            let title = category.title
            let trackers = category.trackers.filter { tracker in
                tracker.schedule.contains(day)
            }
            
            if trackers.count > 0 {
                currentCategories.append(TrackerCategory(title: title, trackers: trackers))
            }
        }
        return currentCategories
    }
    
    private func updateCollectionAccordingToDate() {
        currentCategories = filterCategoriesToShow()
        collectionView.reloadData()
    }
}

//MARK: DataSource
extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.cellIdentifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        cell.counterDelegate = self
        let tracker = currentCategories[indexPath.section].trackers[indexPath.row]
        cell.trackerInfo = TrackerInfoCell(
            id: tracker.id,
            name: tracker.name,
            color: tracker.color,
            emoji: tracker.emoji,
            daysCount: calculateTimesTrackerWasCompleted(id: tracker.id),
            currentDay: currentDate,
            state: tracker.state
        )
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if currentCategories.count == 0 {
            showPlaceHolder()
        } else {
            collectionView.backgroundView = nil
        }
        return currentCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderCollectionReusableView.identifier,
                for: indexPath
            ) as? HeaderCollectionReusableView {
                sectionHeader.titleLabel.text = categories[indexPath.section].title
                return sectionHeader
            }
        }
        return UICollectionReusableView()
    }
}

// MARK: - Delegate
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 16 * 2 - 9
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 46)
    }
}

//MARK: TrackerCounterDelegate
extension TrackerViewController: TrackerCounterDelegate {
    func increaseTrackerCounter(id: UUID, date: Date) {
        try? trackerRecordStore.addRecord(trackerId: id, date: date)
    }
    
    func decreaseTrackerCounter(id: UUID, date: Date) {
        try? trackerRecordStore.deleteRecord(trackerId: id, date: date)
    }
    
    func checkIfTrackerWasCompletedAtCurrentDay(id: UUID, date: Date) -> Bool {
        let contains = completedTrackers.filter {
            $0.id == id && Calendar.current.isDate(
                $0.date,
                equalTo: currentDate,
                toGranularity: .day
            )
        }.count > 0
        return contains
    }
    
    func calculateTimesTrackerWasCompleted(id: UUID) -> Int {
        let contains = completedTrackers.filter {
            $0.id == id
        }
        return contains.count
    }
}

//MARK: - SearchController
extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text != ""{
            updateCollectionAccordingToSearchRequest(trackerToSearch: text)
        }
    }
    
    private func updateCollectionAccordingToSearchRequest(trackerToSearch: String) {
        currentCategories = []
        categories.forEach { category in
            let title = category.title
            let trackers = category.trackers.filter { tracker in
                tracker.name.contains(trackerToSearch)
            }
            if trackers.count > 0 {
                currentCategories.append(TrackerCategory(title: title, trackers: trackers))
            }
        }
        collectionView.reloadData()
    }
}

extension TrackerViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
        updateCollectionAccordingToDate()
    }
}

//MARK: TrackerCreationDelegate
extension TrackerViewController: TrackerCreationDelegate {
    func createTracker(tracker: Tracker, category: String) {
        try? trackerStore.addNewTracker(tracker: tracker, forCategory: category)
        updateCollectionAccordingToDate()
    }
}

//MARK: - TrackerStoreDelegate
extension TrackerViewController: TrackerStoreDelegate {
    func store(insertedIndexes: [IndexPath], deletedIndexes: IndexSet) {
        categories = trackerCategoryStore.categories
        updateCollectionAccordingToDate()
    }
}

//MARK: - TrackerRecordStoreDelegate
extension TrackerViewController: TrackerRecordStoreDelegate {
    func recordUpdate() {
        completedTrackers = trackerRecordStore.completedTrackers
    }
}
