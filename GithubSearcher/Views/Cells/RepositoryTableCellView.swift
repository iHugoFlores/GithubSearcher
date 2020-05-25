//
//  RepositoryTableCellView.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/25/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class RepositoryTableCellView: UITableViewCell {

    static let reuseIdentifier = "RepositoryTableCellView"
    
    private var viewModel: RepositoryCell?
    
    private let mainContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "Repo Name"
        return label
    }()
    
    private let repoDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.numberOfLines = 2
        label.text = "..."
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpMainContainer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpMainContainer() {
        mainContainer.addToAndFill(parent: contentView)
        mainContainer.addArrangedSubview(nameLabel)
        mainContainer.addArrangedSubview(repoDataLabel)
    }
    
    func setUp(viewModel: RepositoryCell) {
        self.viewModel = viewModel
        setInitialValues()
    }
    
    private func setInitialValues() {
        nameLabel.text = viewModel?.getRepoName()
        repoDataLabel.text = viewModel?.getForksAndStarts()
    }
    
}
