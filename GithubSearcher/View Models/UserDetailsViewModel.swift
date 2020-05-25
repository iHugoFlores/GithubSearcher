//
//  UserDetailsViewModel.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class UserDetailsViewModel {
    
    let noQueryMessage = "Type on the search bar to search repos"
    
    private var userDetails: UserDetails!
    
    private var avatarImage: Data!
    
    private var repoQuery: String? {
        didSet {
            guard let value = repoQuery else {
                isDataDownloading = false
                displayMessage = noQueryMessage
                return
            }
            if value.isEmpty {
                isDataDownloading = false
                displayMessage = noQueryMessage
                repoQuery = nil
                repos = []
                return
            }
            isDataDownloading = true
            displayMessage = nil
        }
    }
    
    private var displayMessage: String? {
        didSet {
            guard let handler = setScreenMessageHandler else { return }
            handler(displayMessage)
        }
    }
    
    private var isDataDownloading: Bool = false {
        didSet {
            if oldValue == isDataDownloading { return }
            guard let handler = setActivityIndicatorHandler else { return }
            handler(isDataDownloading)
        }
    }
    
    private var repos: [RepositoryCell] = [] {
        didSet {
            isDataDownloading = false
            guard let handler = reloadTableHandler else { return }
            handler()
        }
    }
    
    var setActivityIndicatorHandler: ((Bool) -> Void)?
    var setScreenMessageHandler: ((String?) -> Void)?
    var reloadTableHandler: (() -> Void)?
    
    init(userDetails: UserDetails, avatar: Data) {
        self.userDetails = userDetails
        self.avatarImage = avatar
    }
    
    func getTitle() -> String {
        return userDetails.login
    }
    
    func getUserAvatar() -> Data {
        return avatarImage
    }
    
    func getUserDescription() -> NSMutableAttributedString {
        let stringContent = NSMutableAttributedString(
            string: "\(userDetails.login)\n",
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
        ])
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        var joinDate = ""
        if let date = dateFormatter.date(from: userDetails.createdAt) {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            joinDate = dateFormatter.string(from: date)
        }
        
        stringContent.append(NSAttributedString(
            string: "\(userDetails.email ?? "No Email")\n\(userDetails.location ?? "No Location")\n\(joinDate)\n",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.gray]
        ))

        stringContent.append(NSAttributedString(
            string: "\(userDetails.followers) followers\nFollowing \(userDetails.following)",
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.gray]
        ))
        return stringContent
    }
    
    func getUserBiography() -> String {
        return userDetails.bio ?? "No biography"
    }
    
    func setNewQuery(query: String) {
        repoQuery = query
    }
    
    func getNewData() {
        if repoQuery == nil { return }
        UserRepository.loadDummyResponse { [unowned self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.repos = self.parseResponseToRepositoryCell(userRepositories: data)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func parseResponseToRepositoryCell(userRepositories: [UserRepository]) -> [RepositoryCell] {
        return userRepositories.map { RepositoryCell(repository: $0) }
    }
    
    func getRepoViewModelAt(indexPath: IndexPath) -> RepositoryCell {
        return repos[indexPath.row]
    }
    
    func getNumberOfRepos() -> Int {
        return repos.count
    }
}
