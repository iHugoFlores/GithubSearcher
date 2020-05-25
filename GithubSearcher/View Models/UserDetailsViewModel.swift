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
    
    private let noQueryMessage = "Type on the search bar to search repos"
    private let noReposMessage = "User has no repos"
    
    private let networkManager: NetworkManager!
    private var previousResponseMeta: APIResponse?
    private var userDetails: UserDetails!
    
    private var avatarImage: Data!
    private var currentPage = 1

    private var repoQuery: String? {
        didSet {
            if userDetails.publicRepos == 0 { return }
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
    var presentAlertHandler: ((String, String, String, (() -> Void)?) -> Void)?
    
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
        UserRepository.getUserRepos(networkManager: networkManager, user: userDetails.login, page: currentPage) {[weak self] (result, response) in
            DispatchQueue.main.async {
                self?.previousResponseMeta = APIResponse(headers: response?.allHeaderFields)
                switch result {
                case .success(let data):
                    self?.repos += (self?.parseResponseToRepositoryCell(userRepositories: data))!
                case .failure:
                    self?.onAPILimitReached()
                }
            }
        }
    }
    
    private func onAPILimitReached() {
        isDataDownloading = false
        guard let handler = presentAlertHandler else { return }
        handler("Download error", "An error has occurred while getting the user repos. Maybe you reched the limit of calls", "Ok", nil)
        displayMessage = "Download Error"
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
    
    func displayAPIInfo() {
        guard let handler = presentAlertHandler else { return }
        guard let response = previousResponseMeta else {
            handler("Make a search", "Start using the application to retrieve information about the API", "Ok", nil)
            return
        }
        
        let resetDate = Date(timeIntervalSince1970: response.rateReset)
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        let resetTime = formatter.string(from: resetDate)
        
        let body = "Call Limit: \(response.rateLimit)\nRemaining Calls: \(response.remaining)\nReset Time: \(resetTime)"
        handler("Latest API Limits", body, "Ok", nil)
    }
    
    func getInitialScreenMessage() -> String {
        return userDetails.publicRepos == 0 ? noReposMessage : noQueryMessage
    }
}
