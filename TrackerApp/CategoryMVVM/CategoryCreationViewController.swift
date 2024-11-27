//
//  NewCategoryViewController.swift
//  TrackerApp
//
//  Created by Ilya Kalin on 25.11.2024.
//

import UIKit

final class CategoryCreationViewController: UIViewController {
    // MARK: - Public Properties
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
    
    // MARK: - Private Properties
    private let saveButton = UIButton()
    private let categoryNameTextField = UITextField()
    private let trackerCategoryStore: TrackerCategoryStore = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to recieve AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        return TrackerCategoryStore(context: context)
    }()
    
    // MARK: - Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Новая категория"
        navigationItem.hidesBackButton = true
        view.backgroundColor = .background
        
        setupSaveButton()
        setupTextField()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Private Methods
    
    private func dynamicColor(_ lightModeColor: UIColor, _ darkModeColor: UIColor) -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? darkModeColor : lightModeColor
        }
    }
    
    @objc
    private func saveButtonTapped() {
        guard let text = categoryNameTextField.text else { return }
        createNewCategory(categoryName: text)
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc
    func textFieldEditingChanged(_ textField: UITextField) {
        guard let text = categoryNameTextField.text else { return }
        if text == "" {
            saveButtonCanBePressed = false
        } else {
            saveButtonCanBePressed = true
        }
    }
    
    private func setupSaveButton() {
        saveButton.setTitle("Готово", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        saveButton.titleLabel?.textColor = dynamicColor(.white, .black)
        saveButton.backgroundColor = dynamicColor(.lightGray, .darkGray)
        saveButton.layer.cornerRadius = 16
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTextField() {
        categoryNameTextField.layer.cornerRadius = 16
        categoryNameTextField.backgroundColor = UIColor(red: 230/255.0, green: 232/255.0, blue: 235/255.0, alpha: 0.3)
        categoryNameTextField.placeholder = "Введите название категории"
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: categoryNameTextField.frame.height))
        categoryNameTextField.leftView = paddingView
        categoryNameTextField.leftViewMode = .always
        categoryNameTextField.clearButtonMode = .whileEditing
        categoryNameTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingDidEnd)
        categoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryNameTextField)
        
        NSLayoutConstraint.activate([
            categoryNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func createNewCategory(categoryName: String) {
        try? trackerCategoryStore.addNewCategory(name: categoryName)
    }
}
