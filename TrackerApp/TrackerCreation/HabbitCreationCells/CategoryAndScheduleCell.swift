//
//  CategoryAndScheduleCell.swift
//  Tracker
//
//  Created by Ilya Kalin on 07.11.2024.
//

import UIKit


protocol ShowScheduleDelegate: AnyObject {
    func showScheduleViewController(viewController: ScheduleViewController)
}

protocol ShowCategoriesDelegate: AnyObject {
    func showCategoriesViewController(viewController: CategoryViewController)
}

final class CategoryAndScheduleCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    
    static let cellIdentifier = "CategoryAndSchedule"
    
    weak var scheduleDelegate: ShowScheduleDelegate?
    weak var categoriesDelegate: ShowCategoriesDelegate?
    
    var tableView = UITableView()
    var state: State?
    var scheduleSubText: String?
    var categorySubText: String?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func updateSubtitleLabel(forCellAt indexPath: IndexPath, text: String) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryAndScheduleTableCell else { return }
        cell.setupSubtitleLabel(text: text)
    }
    
    // MARK: - Private Methods
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CategoryAndScheduleTableCell.self, forCellReuseIdentifier: CategoryAndScheduleTableCell.cellIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.allowsSelection = true
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func configureCell(cell: CategoryAndScheduleTableCell, at indexPath: IndexPath) {
        cell.prepareForReuse()
        
        guard let state = state else { return }
        if state == .habit {
            switch indexPath.row {
            case TrackerTypeSections.category.rawValue:
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.backgroundColor = UIColor(red: 230/255.0, green: 232/255.0, blue: 235/255.0, alpha: 0.3)
                cell.titleLabel.text = NSLocalizedString("categories", comment: "")
                cell.setTitleLabelText(with: "categories")
                cell.accessibilityIdentifier = "CategoryCell"
            case TrackerTypeSections.schedule.rawValue:
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.backgroundColor = UIColor(red: 230/255.0, green: 232/255.0, blue: 235/255.0, alpha: 0.3)
                cell.titleLabel.text = NSLocalizedString("schedule", comment: "")
                cell.setTitleLabelText(with: "schedule")
                cell.accessibilityIdentifier = "ScheduleCell"
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            default:
                return
            }
        } else {
            cell.backgroundColor = UIColor(red: 230/255.0, green: 232/255.0, blue: 235/255.0, alpha: 0.3)
            cell.titleLabel.text = NSLocalizedString("categories", comment: "")
            cell.setTitleLabelText(with: "categories")
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.masksToBounds = true
        }
    }
}

//MARK: Delegate
extension CategoryAndScheduleCell {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if state == .habit {
            return CellSize.two
        } else {
            return CellSize.one
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryAndScheduleTableCell.cellIdentifier, for: indexPath) as? CategoryAndScheduleTableCell else {
            return UITableViewCell()
        }
        
        configureCell(cell: cell, at: indexPath)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return CellSize.one
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellSize.defaultCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == TrackerTypeSections.category.rawValue {
            categoriesDelegate?.showCategoriesViewController(viewController: CategoryViewController())
        } else if indexPath.row == TrackerTypeSections.schedule.rawValue {
            scheduleDelegate?.showScheduleViewController(viewController: ScheduleViewController())
        }
    }
}
