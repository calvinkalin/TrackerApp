//
//  ViewController.swift
//  Tracker
//
//  Created by Ilya Kalin on 22.08.2024.
//

import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - Public Properties
    var placeHolder: PlaceHolderView?
    
    let datePicker = UIDatePicker()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    let pinnedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    let filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("filters", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor.blue
        return button
    }()
    
    // MARK: - Private Properties
    private let presenter = TrackerPresenter()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let questionTextLabel = UILabel()
    private var navigationBar: UINavigationBar?
    
    // MARK: - Overrides Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.reportToAnalyticService(event: .open, params: ["screen" : "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        presenter.reportToAnalyticService(event: .close, params: ["screen" : "Main"])
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        
        presenter.viewController = self
        
        setupCollectionView()
        setupNavigationBar()
        setUpFilterButton()
        
        placeHolder = PlaceHolderView(frame: collectionView.frame)
    }
    
    // MARK: - IBAction
    @objc
    func addTrackerButtonTap() {
        presenter.reportToAnalyticService(event: .click, params: ["screen" : "Main", "item" : "add_track"])
        let createTrackerViewController = NewTrackerViewController()
        createTrackerViewController.delegate = presenter
        let ncCreateTracker = UINavigationController(rootViewController: createTrackerViewController)
        
        navigationController?.present(ncCreateTracker, animated: true)
    }
    
    @objc
    func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        presenter.datePickerWasChanged(date: selectedDate)
    }
    
    @objc
    private func filterButtonPressed() {
        presenter.filterButtonPressed()
    }
    
    // MARK: - Private Methods
    ///MARK: - Setup CollectionView
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        collectionView.register(
            HeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderCollectionReusableView.identifier
        )
        collectionView.backgroundColor = .backgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    ///MARK: - Setup NavigationBar
    private func setupNavigationBar() {
        navigationBar = navigationController?.navigationBar
        
        let image = UIImage(named: "Plus")
        guard let image else { return }
        let plusButton = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(addTrackerButtonTap)
        )
        
        let plusButtonColor = UIColor { (traits: UITraitCollection) -> UIColor in
            if traits.userInterfaceStyle == .light {
                return UIColor.black
            } else {
                return UIColor.white
            }
        }
        plusButton.tintColor = plusButtonColor
        
        plusButton.accessibilityIdentifier = "AddTracker"
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged(_:)),
            for: .valueChanged
        )
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = NSLocalizedString("placeholder.searchbar", comment: "")
        
        navigationBar?.prefersLargeTitles = true
        
        navigationBar?.topItem?.title = NSLocalizedString("trackers", comment: "")
        navigationBar?.topItem?.leftBarButtonItem = plusButton
        navigationBar?.topItem?.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchController
    }
    
    /// MARK: - Setup Filter Button
    private func setUpFilterButton() {
        view.addSubview(filterButton)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func showPlaceHolder() {
        placeHolder?.configurePlaceHolder()
        collectionView.backgroundView = placeHolder
    }
    
    private func deleteTracker(tracker: Tracker) {
        presenter.reportToAnalyticService(event: .click, params: ["screen" : "Main", "item" : "delete"])
        let alert = UIAlertController(
            title: NSLocalizedString("delete.confirmation", comment: ""),
            message: nil,
            preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete", comment: ""),
            style: .destructive) { [weak self] _ in
                guard let self = self else {return}
                self.presenter.deleteTracker(tracker: tracker)
            }
        deleteAction.accessibilityIdentifier = "deleteTrackerConfirmation"
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func editTracker(tracker: TrackerInfoCell, category: TrackerCategory) {
        presenter.editTracker(tracker: tracker, category: category)
    }
    func presentViewController(vc: UIViewController) {
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func pinTracker(tracker:Tracker) {
        presenter.pinTracker(tracker: tracker)
    }
}

//MARK: DataSource
extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        cell.counterDelegate = presenter
        let tracker = presenter.getTracker(forIndexPath: indexPath)
        let category = presenter.getCategory(forIndexPath: indexPath)
        cell.trackerInfo = TrackerInfoCell(
            id: tracker.id,
            name: tracker.name,
            color: tracker.color,
            emoji: tracker.emoji,
            schedule: tracker.schedule,
            daysCount: presenter.calculateTimesTrackerWasCompleted(id: tracker.id),
            currentDay: presenter.currentDate,
            state: tracker.state,
            isPinned: tracker.isPinned
        )
        
        cell.deleteTrackerHandler = { [weak self] tracker in
            self?.deleteTracker(tracker: tracker)
        }
        cell.pinTrackerHandler = { [weak self] tracker in
            self?.pinTracker(tracker: tracker)
        }
        cell.editTrackerHandler = { [weak self] tracker in
            self?.editTracker(tracker: tracker, category: category)
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if presenter.noTrackersToShow() {
            showPlaceHolder()
        } else {
            collectionView.backgroundView = nil
        }
        return presenter.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderCollectionReusableView.identifier,
            for: indexPath) as? HeaderCollectionReusableView {
            
            sectionHeader.titleLabel.text = presenter.getCategory(forIndexPath: indexPath).title
            return sectionHeader
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

//MARK: - Updating Collection
extension TrackerViewController {
    func updateCollectionView() {
        updateFilterButton()
        collectionView.reloadData()
    }
    
    private func updateFilterButton() {
        if presenter.filterButtonShoulBeHidden() {
            filterButton.isHidden = true
        } else {
            filterButton.isHidden = false
        }
        
        if presenter.filterIsActive() {
            filterButton.setTitleColor(.red, for: .normal)
        } else {
            filterButton.setTitleColor(.white, for: .normal)
        }
    }
}

//MARK: - SearchController
extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text != "" {
            placeHolder?.state = PlaceHolderState.noSearchResult
            presenter.updateCollectionAccordingToSearchBarResults(name: text)
            collectionView.reloadData()
        }
    }
}

//MARK: - UISearchBarDelegate
extension TrackerViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
        presenter.updateMainScreen()
    }
}
