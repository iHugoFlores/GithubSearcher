//
//  UserSearchViewModel.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/23/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

class UserSearchViewModel {

    let noQueryMessage = "Type on the search bar to get users"
    
    private let networkManager: NetworkManager!
    
    private var cachedImages = NSCache<NSString, NSData>()
    private var cachedUserDetails = NSCache<NSString, NSString>()
    
    private var users: [UserCell] = [] {
        didSet {
            isDataDownloading = false
            guard let handler = reloadTableHandler else { return }
            handler()
        }
    }

    private var userQuery: String? {
        didSet {
            guard let value = userQuery else {
                isDataDownloading = false
                displayMessage = noQueryMessage
                return
            }
            if value.isEmpty {
                isDataDownloading = false
                displayMessage = noQueryMessage
                userQuery = nil
                users = []
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

    var setScreenMessageHandler: ((String?) -> Void)?
    var setActivityIndicatorHandler: ((Bool) -> Void)?
    var reloadTableHandler: (() -> Void)?
    
    init(networkHandler: NetworkProtocol) {
        networkManager = NetworkManager(networkHandler: networkHandler)
    }

    func setNewQuery(query: String) {
        userQuery = query
    }

    func getNewData() {
        if userQuery == nil { return }
        UsersResponse.loadDummyResponse { [unowned self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.users = self.parseResponseToUserCell(usersResponse: data)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    private func parseResponseToUserCell(usersResponse: UsersResponse) -> [UserCell] {
        return usersResponse.items.map {
            let viewModel = UserCell(user: $0)
            viewModel.avatarDownloadHandler = getUserAvatar
            viewModel.userDetailsDownloadHandler = getUserDetails
            return viewModel
        }
    }

    func getNumberOfUsers() -> Int {
        return users.count
    }

    func getUserViewModelAt(indexPath: IndexPath) -> UserCell {
        return users[indexPath.row]
    }
    
    private func getUserAvatar(url: String, completion: @escaping (Data?) -> Void) {
        if let cachedData = cachedImages.object(forKey: url as NSString) {
            completion(cachedData as Data)
            return
        }
        networkManager.getDataFrom(url: url) { [unowned self] (result) in
            switch result {
            case .success(let imgData):
                completion(imgData)
                self.cachedImages.setObject(imgData as NSData, forKey: url as NSString)
            case .failure(let error):
                print("Error in image download: ", error)
            }
        }
    }

    private func getUserDetails(loginName: String, completion: @escaping (Result<UserDetails, NetworkError>) -> Void) {
        if let cachedUser = cachedUserDetails.object(forKey: loginName as NSString) as String? {
            let user: UserDetails = JSONUtil.jsonToObject(json: cachedUser)
            completion(Result.success(user))
            return
        }
        UserDetails.loadDummyResponse { [unowned self] (result) in
            completion(result)
            switch result {
            case .success(let userDetails):
                let userJSON = JSONUtil.objectToJSON(object: userDetails) as NSString
                let key = loginName as NSString
                self.cachedUserDetails.setObject(userJSON, forKey: key)
            default: break
            }
        }
    }
}
