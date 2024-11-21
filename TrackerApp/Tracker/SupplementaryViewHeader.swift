//
//  SupplementaryViewHeader.swift
//  Tracker
//
//  Created by Ilya Kalin on 17.10.2024.
//

import UIKit

class SupplementaryViewHeader: UICollectionReusableView {
    public let titleLabel = UILabel()
    static let identifier = "Header"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
