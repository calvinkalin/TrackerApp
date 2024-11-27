//
//  OnboardingPageVC.swift
//  TrackerApp
//
//  Created by Ilya Kalin on 25.11.2024.
//

import UIKit

final class OnboardingPageVC: UIViewController {

    // MARK: - Private Properties
    private var text: String?
    private var imageTitle: String?
    private var image = UIImageView()
    private var textLabel = UILabel()

    // MARK: - Initializers
    init(text: String, imageTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.text = text
        self.imageTitle = imageTitle
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupTextLabel()
    }

    // MARK: - Private Methods
    private func setupBackground() {
        guard let imageTitle = imageTitle else { return }

        image.image = UIImage(named: imageTitle)
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)

        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            image.topAnchor.constraint(equalTo: view.topAnchor),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            image.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTextLabel() {
        guard let text = text else { return }

        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)

        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
