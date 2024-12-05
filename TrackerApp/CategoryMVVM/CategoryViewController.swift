//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Ilya Kalin on 24.08.2024.
//

import UIKit

final class CategoryViewController: UIViewController {
    // MARK: - Public Properties
    var categoriesViewModel = CategoriesViewModel()
    
    // MARK: - Private Properties
    private let tableView = UITableView()
    private let createCategoryButton = UIButton()
    
    // MARK: - Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Категория"
        navigationItem.hidesBackButton = true
        view.backgroundColor = .background
        
        setupButton()
        setupTableView()
        
        categoriesViewModel.categoriesBinding = { [weak self] _ in
            guard let self = self else {return}
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Private Methods
    @objc
    private func createCategoryButtonTapped() {
        navigationController?.pushViewController(CategoryCreationViewController(), animated: true)
    }
    
    private func showPlaceholder() {
        let backgroundView = PlaceHolderView(frame: tableView.frame)
        backgroundView.setUpNoCategories()
        tableView.backgroundView = backgroundView
    }
    
    private func dynamicColor(_ lightModeColor: UIColor, _ darkModeColor: UIColor) -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
        }
    }
    
    private func setupButton() {
        createCategoryButton.setTitle("Добавить категорию", for: .normal)
        let buttonBackgroundColor = dynamicColor(.black, .white)
        let buttonTextColor = dynamicColor(.white, .black)
        createCategoryButton.setTitleColor(buttonTextColor, for: .normal)
        createCategoryButton.backgroundColor = buttonBackgroundColor
        createCategoryButton.layer.cornerRadius = 16
        createCategoryButton.addTarget(self, action: #selector(createCategoryButtonTapped), for: .touchUpInside)
        createCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createCategoryButton)
        
        NSLayoutConstraint.activate([
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: createCategoryButton.topAnchor, constant: -16)
        ])
    }
}

//MARK: - TableView Data Source
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (categoriesViewModel.numberOfRows == 0) {
            showPlaceholder()
        } else {
            tableView.backgroundView = nil
        }
        return categoriesViewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let isOnlyOneCell = categoriesViewModel.categories.count == 1
        let isFirstCell = indexPath.row == 0
        let isLastCell = categoriesViewModel.isLastCategory(index: indexPath.row)
        
        cell.prepareForReuse()
        cell.viewModel = categoriesViewModel.categories[indexPath.row]
        if categoriesViewModel.categoryIsChosen(category: cell.viewModel) {
            cell.accessoryType = .checkmark
        }
        
        if isOnlyOneCell {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [
                .layerMaxXMinYCorner,
                .layerMinXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        } else if isFirstCell {
            cell.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
            cell.layer.cornerRadius = 16
        } else if isLastCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            cell.layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
            cell.layer.cornerRadius = 16
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell  else { return }
        cell.accessoryType = .checkmark
        categoriesViewModel.categoryCellWasTapped(at: indexPath.row)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell  else { return }
        cell.accessoryType = .none
    }
}

//MARK: - TableView Delegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
