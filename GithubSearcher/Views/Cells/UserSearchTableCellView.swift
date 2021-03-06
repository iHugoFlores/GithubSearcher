//
//  UserSearchTableCellView.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class UserSearchTableCellView: UITableViewCell {
    
    static let reuseIdentifier = "UserSearchTableCellView"

    private var viewModel: UserCell?

    private let userImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.constraintTo(width: 90, height: 90)
        return image
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let repoNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.text = "..."
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let mainContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return view
    }()

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.setContentHuggingPriority(.required, for: .horizontal)
        return spinner
    }()
    
    private let alertImage = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpMainContainer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpMainContainer() {
        mainContainer.addToAndFill(parent: contentView)
        mainContainer.addArrangedSubview(userImage)
        mainContainer.addArrangedSubview(nameLabel)
        mainContainer.addArrangedSubview(spinner)
    }

    func setUp(viewModel: UserCell) {
        self.viewModel = viewModel
        setInitialValues()
        setUpDataBinding()
    }
    
    private func setUpDataBinding() {
        viewModel?.setImageHandler = setAvatarImage
        viewModel?.setUserReposHandler = setUserRepos
        viewModel?.setLimitReachedHandler = setLimitReachedIndicator
        viewModel?.setErrorHandler = setErrorIndicator
        viewModel?.setActivityIndicatorHandler = setActivityIndicatorState
    }
    
    private func setInitialValues() {
        mainContainer.removeArrangedSubview(alertImage)
        mainContainer.removeArrangedSubview(repoNumberLabel)
        nameLabel.text = viewModel?.getUserName()
    }
    
    private func setAvatarImage(imageData: Data) {
        userImage.image = UIImage(data: imageData)
    }
    
    private func setActivityIndicatorState(isShowing: Bool) {
        if isShowing {
            spinner.startAnimating()
        } else {
            mainContainer.removeArrangedSubview(spinner)
            spinner.stopAnimating()
        }
    }
    
    private func setUserRepos(text: String) {
        repoNumberLabel.text = text
        mainContainer.addArrangedSubview(repoNumberLabel)
        mainContainer.removeArrangedSubview(alertImage)
    }
    
    private func setLimitReachedIndicator() {
        mainContainer.addArrangedSubview(alertImage)
        alertImage.image = UIImage(systemName: "hourglass.tophalf.fill")
        alertImage.tintColor = .systemYellow
        alertImage.contentMode = .scaleAspectFit
        alertImage.constraintTo(width: 24, height: 24)
        mainContainer.removeArrangedSubview(repoNumberLabel)
        repoNumberLabel.removeFromSuperview()
    }
    
    private func setErrorIndicator() {
        mainContainer.addArrangedSubview(alertImage)
        alertImage.image = UIImage(systemName: "xmark.circle")
        alertImage.tintColor = .systemRed
        alertImage.contentMode = .scaleAspectFit
        alertImage.constraintTo(width: 24, height: 24)
        mainContainer.removeArrangedSubview(repoNumberLabel)
        repoNumberLabel.removeFromSuperview()
    }
}
