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
    
    private let userImage: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "plus"))
        image.contentMode = .scaleAspectFit
        image.constraintTo(width: 60, height: 60)
        return image
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.text = "Hello"
        return label
    }()
    
    private let repoNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.text = "12 repos"
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        print("I am here2?")
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("I am here?")
        setUpViews()
    }
    
    func setUpViews() {
//        userImage.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(userImage)
//        userImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
//        userImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
//        userImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        setUpMainContainer()
    }
    
    func setUpMainContainer() {
        mainContainer.addToAndFill(parent: contentView)
        mainContainer.addArrangedSubview(userImage)
        mainContainer.addArrangedSubview(nameLabel)
        mainContainer.addArrangedSubview(repoNumberLabel)
    }
}
