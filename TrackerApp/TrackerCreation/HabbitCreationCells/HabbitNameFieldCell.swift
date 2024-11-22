//
//  HabbitNameField.swift
//  Tracker
//
//  Created by Ilya Kalin on 07.11.2024.
//

import UIKit

protocol SaveNameTrackerDelegate: AnyObject {
    func textFieldWasChanged(text: String)
}

final class HabitNameCell: UICollectionViewCell {
    weak var delegate: SaveNameTrackerDelegate?

    static let cellIdentifier = "HabitNameCell"
    private let textField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func textFieldChanged() {
        delegate?.textFieldWasChanged(text: textField.text ?? "")
    }
    
    private func setupTextField() {
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.backgroundColor = UIColor(red: 230/255.0, green: 232/255.0, blue: 235/255.0, alpha: 0.3)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        contentView.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
