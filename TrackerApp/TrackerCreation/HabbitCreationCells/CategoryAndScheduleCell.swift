//
//  CategoryAndScheduleCell.swift
//  Tracker
//
//  Created by Ilya Kalin on 07.11.2024.
//

import UIKit

enum State {
    case Habit
    case Event
}

protocol ShowScheduleDelegate: AnyObject {
    func showShowScheduleViewController(viewController: ScheduleViewController)
}

protocol ShowCategoriesDelegate: AnyObject {
    func showCategoriesViewController()
}

class CategoryAndScheduleCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    

    static let cellIdentifier = "CategoryAndSchedule"
    
    weak var scheduleDelegate: ShowScheduleDelegate?
    weak var categoriesDelegate: ShowCategoriesDelegate?
    
    private enum Sections: Int, CaseIterable {
        case category = 0
        case schedule
    }
    
    private let items = ["Категория", "Расписание"]

    
    var tableView = UITableView()
    var state: State? = .Habit

    
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
        guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CategoryAndScheduleTableCell else { return }
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
        
        cell.layer.maskedCorners = []
        cell.layer.cornerRadius = 0
        cell.layer.masksToBounds = false

        
        guard let state = state else { return }
        if state == .Habit {
            switch indexPath.row {
            case Sections.category.rawValue:
                cell.backgroundColor = UIColor(red: 230/255.0, green: 232/255.0, blue: 235/255.0, alpha: 0.3)
                cell.titleLabel.text = "Категория"
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.layer.masksToBounds = true
            case Sections.schedule.rawValue:
                cell.backgroundColor = UIColor(red: 230/255.0, green: 232/255.0, blue: 235/255.0, alpha: 0.3)
                cell.titleLabel.text = "Расписание"
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.layer.masksToBounds = true
            default:
                return
            }
        } else {
            cell.backgroundColor = UIColor(red: 230/255.0, green: 232/255.0, blue: 235/255.0, alpha: 0.3)
            cell.titleLabel.text = "Категории"
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
        if state == .Habit {
            return items.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryAndScheduleTableCell.cellIdentifier, for: indexPath) as? CategoryAndScheduleTableCell else {
            return UITableViewCell()
        }
        
        configureCell(cell: cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == Sections.category.rawValue {
            categoriesDelegate?.showCategoriesViewController()
        } else if indexPath.row == Sections.schedule.rawValue {
            scheduleDelegate?.showShowScheduleViewController(viewController: ScheduleViewController())
        }
    }
}


