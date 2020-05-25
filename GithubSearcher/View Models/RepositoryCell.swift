//
//  RepositoryCell.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/25/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit
import UIKit.UINavigationController

class RepositoryCell {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func getRepoName() -> String {
        return repository.name
    }
    
    func getForksAndStarts() -> String {
        return "\(repository.forksCount) Forks\n\(repository.stargazersCount) Stars"
    }
    
    func navigateToWebRepo(navigationController: UINavigationController?) {
        guard let url = URL(string: repository.htmlURL) else { return }
        let newView = WebView(request: URLRequest(url: url))
        navigationController?.pushViewController(newView, animated: true)
    }
}
