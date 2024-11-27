//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Ilya Kalin on 22.08.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - Private Properties
    private var navigationBar: UINavigationBar?
    private let tableView = UITableView()
    private var trackerRecordStore: TrackerRecordStore = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to recieve AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        return TrackerRecordStore(context: context)
    }()
    private var placeHolderView = UIView()

    private var score: Int {
        return calculateCompletedTrackers()
    }

    // MARK: - Overrides Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor

        setupNavigationBarTittle()
        initTableView()
        setupPlaceHolder()
    }

    // MARK: - Private Methods
    private func setupNavigationBarTittle() {
        navigationBar = navigationController?.navigationBar
        navigationBar?.prefersLargeTitles = true
        navigationBar?.topItem?.title = NSLocalizedString("statistics", comment: "")
    }

    private func setupPlaceHolder() {
        let width = view.safeAreaLayoutGuide.layoutFrame.width
        let height = view.safeAreaLayoutGuide.layoutFrame.height
        guard let inset = self.navigationBar?.frame.size.height else { return }
        let placeHolder = PlaceHolderView(frame: CGRect(x: 0, y: 0, width: width, height: height - 2 * inset))
        placeHolderView.translatesAutoresizingMaskIntoConstraints = false
        placeHolder.state = .noStatistic
        placeHolder.configurePlaceHolder()
        view.addSubview(placeHolderView)
        placeHolderView.addSubview(placeHolder)
        NSLayoutConstraint.activate([
            placeHolderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            placeHolderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            placeHolderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            placeHolderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            placeHolder.centerXAnchor.constraint(equalTo: placeHolderView.safeAreaLayoutGuide.centerXAnchor),
            placeHolder.centerYAnchor.constraint(equalTo: placeHolderView.safeAreaLayoutGuide.centerYAnchor),
        ])
    }

    private func calculateCompletedTrackers() -> Int {
        guard let result = try? trackerRecordStore.calculateCompletedTrackers() else {
            return .zero
        }
        return result
    }

    private func initTableView() {
        tableView.register(StatisticsTableCell.self, forCellReuseIdentifier: StatisticsTableCell.identifier)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.backgroundColor = .backgroundColor
        tableView.layer.cornerRadius = 16
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: (24+53)),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}

//MARK: - Data Source
extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if score == 0 {
            placeHolderView.isHidden = false
            return .zero
        } else {
            placeHolderView.isHidden = true
            return CellSize.one
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableCell.identifier, for: indexPath) as? StatisticsTableCell else {
            return UITableViewCell()
        }
        cell.prepareForReuse()
        cell.setNameLabel()
        cell.setScore(with: score)
        return cell
    }

}

//MARK: - TableView Delegate
extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellSize.statisticsCellHeight
    }
}
