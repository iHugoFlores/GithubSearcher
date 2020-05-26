//
//  LoginViewModel.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/26/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import Foundation

class LoginViewModel {
    private let networkManager: NetworkManager!

    var presentAlertHandler: ((String, String, String, (() -> Void)?) -> Void)?
    var setActivityIndicatorHandler: ((Bool) -> Void)?
    var dismissHandler: (() -> Void)?
    
    init(networkHandler: NetworkProtocol) {
        networkManager = NetworkManager(networkHandler: networkHandler)
        
    }
    
    private var isDataDownloading: Bool = false {
        didSet {
            guard let handler = setActivityIndicatorHandler else { return }
            handler(isDataDownloading)
        }
    }

    func onButtonPressed(userName: String?, password: String?) {
        if checkIfLoggedUserExists() {
            eliminateStoredUser()
            return
        }
        guard let handler = presentAlertHandler else { return }
        guard let name = userName, let pass = password, !(name.isEmpty || pass.isEmpty) else {
            handler("Missing credentials", "Insert you user name and password to authenticate in Github", "On", nil)
            return
        }
        validateCredentials(userName: name, password: pass)
    }
    
    private func validateCredentials(userName: String, password: String) {
        isDataDownloading = true
        LoginResponse.validateCredentials(networkManager: networkManager, user: userName, password: password) { [weak self] (result, response) in
            DispatchQueue.main.async {
                self?.isDataDownloading = false
                switch result {
                case .success:
                    self?.onUserValidated(user: userName, password: password)
                case .failure(let error):
                    guard let handler = self?.presentAlertHandler else { return }
                    switch error {
                    case .unauthorized:
                        handler("Invalid credentials", "The user name or password introduced were incorrect", "Ok", nil)
                    default:
                        handler("Unexpected Error", "An unexpected error has ocurred", "Ok", nil)
                    }
                }
            }
        }
    }

    private func eliminateStoredUser() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Constants.UserDefaults.USER)
        defaults.removeObject(forKey: Constants.UserDefaults.PASSWORD)
        guard let handler = presentAlertHandler, let dismiss = dismissHandler else { return }
        handler("Logged Out", "Your credentials have been deleted from the device", "Return", dismiss)
    }

    private func onUserValidated(user: String, password: String) {
        let defaults = UserDefaults.standard
        defaults.set(user, forKey: Constants.UserDefaults.USER)
        defaults.set(password, forKey: Constants.UserDefaults.PASSWORD)
        guard let handler = presentAlertHandler, let dismiss = dismissHandler else { return }
        handler("Logged in", "You can now perform more requests", "Return", dismiss)
    }
    
    func checkIfLoggedUserExists() -> Bool {
        return UserDefaults.standard.string(forKey: Constants.UserDefaults.USER) != nil
    }
}
