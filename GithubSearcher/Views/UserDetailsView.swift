//
//  UserDetailsView.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class UserDetailsView: UIViewController {
    
    private var viewModel: UserDetailsViewModel!
    
    private let userImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.constraintTo(width: 120, height: 120)
        return image
    }()

    private let userDataLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let biograpgyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let topContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 6
        view.distribution = .fillEqually
        view.alignment = .center
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return view
    }()

    init(viewModel: UserDetailsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Github Searcher"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setUpViews()
        setUpInitData()
    }
    
    private func setUpViews() {
        view.addSubview(topContainer)
        topContainer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        topContainer.addArrangedSubview(userImage)
        topContainer.addArrangedSubview(userDataLabel)

        view.addSubview(biograpgyLabel)
        biograpgyLabel.topAnchor.constraint(equalTo: topContainer.bottomAnchor).isActive = true
        biograpgyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        biograpgyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true        
    }
    
    private func setUpInitData() {
        userImage.image = UIImage(data: viewModel.getUserAvatar())
        userDataLabel.attributedText = viewModel.getUserDescription()
        biograpgyLabel.text = viewModel.getUserBiography()
    }
}
