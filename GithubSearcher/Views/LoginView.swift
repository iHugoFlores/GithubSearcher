//
//  LoginView.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/26/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class LoginView: UIViewController {
    
    private let topBar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.pushItem(UINavigationItem(title: "..."), animated: false)
        bar.backgroundColor = .systemBackground
        return bar
    }()
    
    private let horizontalContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return view
    }()
    
    private let verticalContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 12
        return view
    }()
    
    private let mainContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 12
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return view
    }()
    
    private let userField: RoundedTextField = {
        let field = RoundedTextField()
        field.placeholder = "User Name"
        return field
    }()
    
    private let passwordField: RoundedTextField = {
        let field = RoundedTextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .black
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return button
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .gray
        label.text = """
        - The app uses the deprecated Basic Authentication method. This service wil shut down on November 13, 2020 at 4:00 PM UTC

        - The app handles the data inputed in the above fieds with NO ENCRYPTION. Use it at your own risk
        """
        return label
    }()
    
    private let spinnerView: SpinnerView = {
        let view = SpinnerView()
        return view
    }()
    
    private var viewModel: LoginViewModel!
    
    init(viewModel: LoginViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        setUpDataBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpDataBinding() {
        viewModel.presentAlertHandler = displayAlert
        viewModel.setActivityIndicatorHandler = setActivityIndicatorState
        viewModel.dismissHandler = dismissView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setUpViews()
    }
    
    private func setUpViews() {
        topBar.addAtTopOf(parent: view)
        topBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissView))
        loginButton.addTarget(self, action: #selector(onButtonPressed), for: .touchUpInside)
        viewModel.checkIfLoggedUserExists()
            ? renderLogoutView()
            : renderLoginView()
    }
    
    private func renderLoginView() {
        topBar.topItem?.title = "Log in to Github"
        verticalContainer.addArrangedSubview(userField)
        verticalContainer.addArrangedSubview(passwordField)
        horizontalContainer.addArrangedSubview(verticalContainer)
        horizontalContainer.addArrangedSubview(loginButton)
        loginButton.setTitle("Login", for: .normal)
        
        mainContainer.addArrangedSubview(horizontalContainer)
        mainContainer.addArrangedSubview(warningLabel)
        
        mainContainer.addAtTopOf(parent: view, below: topBar)
    }
    
    private func renderLogoutView() {
        topBar.topItem?.title = "Log out from Github"
        mainContainer.addArrangedSubview(loginButton)
        loginButton.setTitle("Logout", for: .normal)
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 24, left: 12, bottom: 24, right: 12)
        mainContainer.addAtTopOf(parent: view, below: topBar)
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onButtonPressed() {
        viewModel.onButtonPressed(userName: userField.text, password: passwordField.text)
    }
    
    private func displayAlert(title: String, message: String, buttonMessage: String, callback: (() -> Void)?) {
        let handler = { (action: UIAlertAction) in
            if let callback = callback { callback() }
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonMessage, style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }
    
    private func setActivityIndicatorState(isShowing: Bool) {
        isShowing ? spinnerView.presentOn(parent: view) : spinnerView.stop()
    }
}
