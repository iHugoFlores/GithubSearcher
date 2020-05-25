//
//  UserDetailsViewModel.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation
import  UIKit.UIColor
import  UIKit.UIFont

class UserDetailsViewModel {
    
    let noQueryMessage = "Type on the search bar to search repos"
    
    private let networkManager: NetworkManager!
    
    private var userDetails: UserDetails!
    
    private var avatarImage: Data!
    private var currentPage = 1

    private var repoQuery: String? {
        didSet {
            guard let value = repoQuery else { return }
            if value.isEmpty {
                repoQuery = nil
                filteredRepos = repos
                return
            }
            displayMessage = nil
            filterBy(query: value)
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
            guard let query = repoQuery else { return }
            filterBy(query: query)
        }
    }
    
    private var filteredRepos: [RepositoryCell] = [] {
        didSet {
            guard let handler = reloadTableHandler else { return }
            handler()
            if filteredRepos.isEmpty && repoQuery != nil && !repos.isEmpty {
                displayMessage = "No repos found"
            }
        }
    }
    
    var setActivityIndicatorHandler: ((Bool) -> Void)?
    var setScreenMessageHandler: ((String?) -> Void)?
    var reloadTableHandler: (() -> Void)?
    
    init(networkHandler: NetworkProtocol, userDetails: UserDetails, avatar: Data) {
        networkManager = NetworkManager(networkHandler: networkHandler)
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
        if repos.count >= userDetails.publicRepos { return }
        isDataDownloading = true
        UserRepository.getUserRepos(networkManager: networkManager, user: userDetails.login, page: currentPage) { (result, response) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.repos += self.parseResponseToRepositoryCell(userRepositories: data)
                case .failure(let error):
                    print("User repo get user repo error", error)
                }
            }
        }
    }
    
    private func parseResponseToRepositoryCell(userRepositories: [UserRepository]) -> [RepositoryCell] {
        return userRepositories.map { RepositoryCell(repository: $0) }
    }
    
    func getRepoViewModelAt(indexPath: IndexPath) -> RepositoryCell {
        return filteredRepos[indexPath.row]
    }
    
    func getNumberOfRepos() -> Int {
        return filteredRepos.count
    }
    
    func checkForNewPage(indexPath: IndexPath) {
        if indexPath.row < repos.count - 1 { return }
        getNewPage()
    }
    
    func getNewPage() {
        if repos.count >= userDetails.publicRepos || isDataDownloading { return }
        isDataDownloading = true
        currentPage += 1
        getNewData()
    }
    
    private func filterBy(query: String) {
        filteredRepos = repos.filter { $0.getRepoName().localizedCaseInsensitiveContains(query) }
    }
}
