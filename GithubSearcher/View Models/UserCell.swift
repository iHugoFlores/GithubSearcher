//
//  UserCell.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

class UserCell {
    private let user: User
    
    var setImageHandler: ((Data) -> Void)? {
        didSet {
            getAvatarImage()
        }
    }
    
    var setActivityIndicatorHandler: ((Bool) -> Void)? {
        didSet {
            getUserDetails()
        }
    }
    
    var userAvatar: Data? {
        didSet {
            guard let handler = setImageHandler else { return }
            guard let imageData = userAvatar else { return }
            handler(imageData)
        }
    }
    
    private var isDataDownloading: Bool = false {
        didSet {
            guard let handler = setActivityIndicatorHandler else { return }
            handler(isDataDownloading)
        }
    }
    
    private var userDetails: UserDetails? {
        didSet {
            guard let details = userDetails, let handler = setUserReposHandler else { return }
            let repos = "\(details.publicRepos) \(details.publicRepos > 1 ? "repos" : "repo")"
            handler(repos)
            isDataDownloading = false
        }
    }
    
    private var error: NetworkError? {
        didSet {
            print("Error")
        }
    }
    
    var avatarDownloadHandler: ((String, @escaping (Data?) -> Void) -> Void)?
    var userDetailsDownloadHandler: ((String, @escaping (Result<UserDetails, NetworkError>) -> Void) -> Void)?
    var setUserReposHandler: ((String) -> Void)?

    init(user: User) {
        self.user = user
    }

    func getUserName() -> String {
        return user.login
    }

    func getUserAvararURL() -> String {
        return user.avatarURL
    }
    
    private func getAvatarImage() {
        guard let handler = avatarDownloadHandler else { return }
        handler(user.avatarURL) { [weak self] data in
            DispatchQueue.main.async {
                self?.userAvatar = data
            }
        }
    }
    
    private func getUserDetails() {
        guard let handler = userDetailsDownloadHandler else { return }
        isDataDownloading = true
        handler(user.login) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userDetails):
                    self?.userDetails = userDetails
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}
