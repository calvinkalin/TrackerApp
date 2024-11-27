//
//  PlaceHolderView.swift
//  Tracker
//
//  Created by Ilya Kalin on 18.11.2024.
//

import UIKit

enum PlaceHolderState {
    case noCategories
    case noTrackers
    case noSearchResult
    case noStatistic
}

final class PlaceHolderView: UIView {
    // MARK: - Public Properties
    var state: PlaceHolderState = .noTrackers
    
    // MARK: - Private Properties
    private var imageView = UIImageView()
    private var label = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configurePlaceHolder() {
        switch state {
        case .noTrackers:
            setUpNoTrackersState()
        case .noCategories:
            setUpNoCategories()
        case .noSearchResult:
            setUpNoSearchResultsState()
        case .noStatistic:
            setUpNoStatisticState()
        }
    }
    
    func setUpNoTrackersState() {
        let image = UIImage(named: "Nothing")
        imageView.image = image
        label.text = NSLocalizedString("placeholder.noTrackers", comment: "")
    }
    
    func setUpNoSearchResultsState() {
        let image = UIImage(named: "notFound")
        imageView.image = image
        
        label.text = NSLocalizedString("placeholder.noSearchResults", comment: "")
    }
    
    func setUpNoCategories() {
        let image = UIImage(named: "Nothing")
        imageView.image = image
        
        label.text = NSLocalizedString("placeholder.noCategories", comment: "")
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
    }
    
    func setUpNoStatisticState() {
        let image = UIImage(named: "noStatistic")
        imageView.image = image
        label.text = NSLocalizedString("placeholder.noStatistics", comment: "")
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
    }
    
    // MARK: - Private Methods
    private func setupView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
