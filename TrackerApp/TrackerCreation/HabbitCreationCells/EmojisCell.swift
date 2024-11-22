//
//  EmojisCell.swift
//  Tracker
//
//  Created by Ilya Kalin on 07.11.2024.
//

import UIKit

final class EmojisCell: UICollectionViewCell {
    // MARK: - Public Properties
    static let cellIdentifier = "EmojisCell"
    
    let label = UILabel()
            
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = self.isSelected ? UIColor.lightGray : .clear
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 16
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupLabel() {
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
