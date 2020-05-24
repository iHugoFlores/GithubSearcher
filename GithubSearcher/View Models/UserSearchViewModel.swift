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

    private var usersResponse: UsersResponse? {
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
                usersResponse = nil
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

    func setNewQuery(query: String) {
        userQuery = query
    }

    func getNewData() {
        if userQuery == nil { return }
        UsersResponse.loadDummyResponse { [unowned self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.usersResponse = data
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func getNumberOfUsers() -> Int {
        return usersResponse?.items.count ?? 0
    }
}
