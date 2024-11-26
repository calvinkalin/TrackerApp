//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Ilya Kalin on 23.08.2024.
//

import UIKit

class TrackerCreationViewController: UIViewController {
    
    weak var delegate: TrackerCreationDelegate?
    
    private var navigationBar: UINavigationBar?
    
    private let addHabitButton = UIButton()
    private let addEventButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpHabitButton()
        setUpEventButton()
        setUpNavigationBar()
    }
    
    @objc
    func didTapHabitButton() {
        
        let vc = HabitCreationViewController()
        vc.closeCreatingTrackerViewController = { [weak self] in
            guard let self = self else {return}
            self.dismiss(animated: true)
        }
        let navigationController = UINavigationController(rootViewController: vc)
        vc.creationDelegate = delegate
        present(navigationController, animated: true)
    }
    
    @objc
    func didTapEventButton() {
        
    }
}

extension TrackerCreationViewController {
    func setUpNavigationBar() {
        navigationBar = navigationController?.navigationBar
        navigationBar?.isHidden = false
        navigationItem.title = "Создание трекера"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 16, weight: .regular)]
    }
    
    func setUpHabitButton() {
        addHabitButton.setTitle("Привычка", for: .normal)
        addHabitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addHabitButton.titleLabel?.textColor = .white
        addHabitButton.backgroundColor = .black
        addHabitButton.layer.cornerRadius = 16
        addHabitButton.translatesAutoresizingMaskIntoConstraints = false
        addHabitButton.addTarget(self, action: #selector(didTapHabitButton), for: .touchUpInside)
        view.addSubview(addHabitButton)
        
        NSLayoutConstraint.activate([
            addHabitButton.heightAnchor.constraint(equalToConstant: 60),
            addHabitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    func setUpEventButton() {
        addEventButton.setTitle("Нерегулярное событие", for: .normal)
        addEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addEventButton.titleLabel?.textColor = .white
        addEventButton.backgroundColor = .black
        addEventButton.layer.cornerRadius = 16
        addEventButton.translatesAutoresizingMaskIntoConstraints = false
        addEventButton.addTarget(self, action: #selector(didTapEventButton), for: .touchUpInside)
        view.addSubview(addEventButton)
        
        NSLayoutConstraint.activate([
            addEventButton.topAnchor.constraint(equalTo: addHabitButton.bottomAnchor, constant: 16),
            addEventButton.heightAnchor.constraint(equalToConstant: 60),
            addEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
}

