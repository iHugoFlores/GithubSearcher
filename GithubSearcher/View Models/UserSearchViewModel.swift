//
//  UserSearchViewModel.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/23/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation
import UIKit.UINavigationController

class UserSearchViewModel {

    let noQueryMessage = "Type on the search bar to get users"
    private let noUsersFoundMessage = "No Users Found"
    
    private let networkManager: NetworkManager!
    
    // private let userDetailsSemaphore = DispatchSemaphore(value: 0)
    private var cachedImages = NSCache<NSString, NSData>()
    private var cachedUserDetails = NSCache<NSString, NSString>()
    
    private var currentPage = 1
    private var maxNumberOfUsers = 0

    private var previousResponseMeta: APIResponse?
    
    private var users: [UserCell] = [] {
        didSet {
            isDataDownloading = false
            guard let handler = reloadTableHandler else { return }
            handler()
            if users.isEmpty {
                maxNumberOfUsers = 0
                currentPage = 1
                displayMessage = noUsersFoundMessage
            }
        }
    }

    private var userQuery: String? {
        didSet {
            guard let value = userQuery else {
                isDataDownloading = false
                displayMessage = noQueryMessage
                return
            }
            users = []
            if value.isEmpty {
                isDataDownloading = false
                displayMessage = noQueryMessage
                userQuery = nil
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
    var presentAlertHandler: ((String, String, String, (() -> Void)?) -> Void)?
    
    init(networkHandler: NetworkProtocol) {
        networkManager = NetworkManager(networkHandler: networkHandler)
    }

    func setNewQuery(query: String) {
        userQuery = query
    }

    func getNewData() {
        guard let query = userQuery else { return }
        UsersResponse.getUsers(networkManager: networkManager, query: query, page: currentPage) { (result, response) in
            self.previousResponseMeta = APIResponse(headers: response?.allHeaderFields)
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.maxNumberOfUsers = data.totalCount
                    self.users += self.parseResponseToUserCell(usersResponse: data)
                case .failure(let error):
                    self.isDataDownloading = false
                    switch error {
                    case .deviceOffline:
                        self.displayAlertMessage(title: "Connection Error", body: "The device is offline. Connect to a network and try again", buttonMsg: "Try Again", callback: self.reTryNewDataDownload)
                    case .rateLimitReached:
                        self.onAPILimitReached()
                    default:
                        self.displayAlertMessage(title: "Unexpected Error", body: "An unexpected error has ocurred", buttonMsg: "Try Again", callback: self.reTryNewDataDownload)
                    }
                }
            }
        }
    }
    
    private func onAPILimitReached() {
        self.displayAlertMessage(title: "Requests Limit reached", body: "The API Request Limit has been reached. Press the information button to see the reset time", buttonMsg: "Ok")
        userQuery = ""
    }
    
    private func reTryNewDataDownload() {
        isDataDownloading = true
        getNewData()
    }
    
    func checkForNewPage(indexPath: IndexPath) {
        if indexPath.row < users.count - 1 { return }
        getNewPage()
    }
    
    func getNewPage() {
        if users.count >= maxNumberOfUsers || isDataDownloading { return }
        isDataDownloading = true
        currentPage += 1
        getNewData()
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
        networkManager.getDataFrom(url: url) { [unowned self] (result, _) in
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
        UserDetails.getUserDetails(networkManager: networkManager, user: loginName) {[weak self] (result, response) in
            self?.previousResponseMeta = APIResponse(headers: response?.allHeaderFields)
            completion(result)
            switch result {
            case .success(let userDetails):
                let userJSON = JSONUtil.objectToJSON(object: userDetails) as NSString
                let key = loginName as NSString
                self?.cachedUserDetails.setObject(userJSON, forKey: key)
            default: break
            }
            // self?.userDetailsSemaphore.signal()
        }
        // self.userDetailsSemaphore.wait()
    }
    
    func displayAPIInfo() {
        guard let response = previousResponseMeta else {
            displayAlertMessage(title: "Make a search", body: "Start using the application to retrieve information about the API", buttonMsg: "Ok")
            return
        }
        
        let resetDate = Date(timeIntervalSince1970: response.rateReset)
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        let resetTime = formatter.string(from: resetDate)
        
        let callLimit = response.rateLimit < 0 ? "No Limit" : String(response.rateLimit)
        let callRemain = response.remaining < 0 ? "No Limit" : String(response.remaining)
        
        let body = "Call Limit: \(callLimit)\nRemaining Calls: \(callRemain)\nReset Time: \(resetTime)"
        displayAlertMessage(title: "Latest API Limits", body: body, buttonMsg: "Ok")
    }
    
    func displayAlertMessage(title: String, body: String, buttonMsg: String, callback: (() -> Void)? = nil) {
        guard let handler = presentAlertHandler else { return }
        handler(title, body, buttonMsg, callback)
    }
    
    func navigateToLogin(navigationController: UINavigationController?) {
        let loginViewModel = LoginViewModel(networkHandler: networkManager.networkHandler)
        let newView = LoginView(viewModel: loginViewModel)
        newView.isModalInPresentation = true
        navigationController?.present(newView, animated: true, completion: nil)
    }
}
