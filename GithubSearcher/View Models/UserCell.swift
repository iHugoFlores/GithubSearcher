//
//  UserCell.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation
import UIKit.UINavigationController

class UserCell {
    private let user: User
    
    var setImageHandler: ((Data) -> Void)? {
        didSet {
            getAvatarImage()
        }
    }
    
    var setActivityIndicatorHandler: ((Bool) -> Void)? {
        didSet {
            if let details = userDetails {
                guard let handler = setUserReposHandler else { return }
                let repos = "\(details.publicRepos) \(details.publicRepos > 1 ? "repos" : "repo")"
                handler(repos)
                return
            }
            if let error = error {
                switch error {
                case .rateLimitReached:
                    guard let handler = setLimitReachedHandler else { return }
                    handler()
                default:
                    guard let handler = setErrorHandler else { return }
                    handler()
                }
            }
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
            if error != nil { return }
            guard let details = userDetails, let handler = setUserReposHandler else { return }
            let repos = "\(details.publicRepos) \(details.publicRepos > 1 ? "repos" : "repo")"
            handler(repos)
            isDataDownloading = false
        }
    }
    
    var error: NetworkError? {
        didSet {
            isDataDownloading = false
            switch error {
            case .rateLimitReached:
                guard let handler = setLimitReachedHandler else { return }
                handler()
            default:
                guard let handler = setErrorHandler else { return }
                handler()
            }
        }
    }
    
    var avatarDownloadHandler: ((String, @escaping (Data?) -> Void) -> Void)?
    var userDetailsDownloadHandler: ((String, @escaping (Result<UserDetails, NetworkError>) -> Void) -> Void)?
    var setUserReposHandler: ((String) -> Void)?
    var setLimitReachedHandler: (() -> Void)?
    var setErrorHandler: (() -> Void)?
    var presentAlertHandler: ((String, String, String, (() -> Void)?) -> Void)?

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
        if userDetails != nil || error != nil { return }
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
    
    func navigateToDetails(navigationController: UINavigationController?) {
        if !shouldNavigate() { return }
        guard let model = userDetails, let image = userAvatar else { return }
        let detailsViewModel = UserDetailsViewModel(networkHandler: NetworkEngine(), userDetails: model, avatar: image)
        let newView = UserDetailsView(viewModel: detailsViewModel)
        navigationController?.pushViewController(newView, animated: true)
    }
    
    private func shouldNavigate() -> Bool {
        if userDetails == nil {
            guard let handler = presentAlertHandler else { return false }
            handler("Can't go to details", "An error has occurred while getting the user details. Maybe you reched the limit of calls", "Ok", nil)
            return false
        }
        return true
    }
}
