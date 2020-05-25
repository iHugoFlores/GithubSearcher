//
//  RepositoryCell.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/25/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

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
}
