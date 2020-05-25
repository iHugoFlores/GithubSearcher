//
//  UserSearchView.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/23/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class UserSearchView: UIViewController {
    
    private var viewModel: UserSearchViewModel!
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search for Users"
        bar.setContentHuggingPriority(.required, for: .vertical)
        return bar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.tableFooterView = UIView()
        table.estimatedRowHeight = 10
        table.rowHeight = UITableView.automaticDimension
        return table
    }()
    
    private var tableBottomConstraint: NSLayoutConstraint?
    private var tableBottomKeyboardConstraint: NSLayoutConstraint?
    
    private let spinner = UIActivityIndicatorView(style: .large)
    
    private let spinnerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        return view
    }()

    init(viewModel: UserSearchViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        setUpDataBinding()
    }
    
    func setUpDataBinding() {
        viewModel.setScreenMessageHandler = displayOnTable
        viewModel.setActivityIndicatorHandler = setActivityIndicatorState
        viewModel.reloadTableHandler = reloadTableData
        viewModel.presentAlertHandler = displayAlert
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Github Searcher"
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(onInfoPressed))
        setUpViews()
        setUpNotifications()
    }
    
    @objc private func onInfoPressed() {
        viewModel.displayAPIInfo()
    }
    
    private func setUpViews() {
        setUpSearchBar()
        setUpTable()
    }
    
    private func setUpSearchBar() {
        searchBar.delegate = self
        searchBar.addAtTopOf(parent: view)
    }
    
    private func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserSearchTableCellView.self, forCellReuseIdentifier: UserSearchTableCellView.reuseIdentifier)
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        tableBottomConstraint?.isActive = true
        displayOnTable(message: viewModel.noQueryMessage)
    }
    
    private func setUpNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func adjustForKeyboard(notification: NSNotification) {
        if notification.name == UIResponder.keyboardWillShowNotification,
           let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableBottomConstraint?.constant = -keyboardSize.height
        } else {
            tableBottomConstraint?.constant = 0
        }
        
        UIView.animate(
            withDuration: 0.33,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.view.layoutIfNeeded()
        },
            completion: nil)
    }
    
    @objc private func executeNewSearch() {
        viewModel.getNewData()
    }
    
    private func displayOnTable(message: String?) {
        guard let message = message else {
            tableView.backgroundView = nil
            return
        }
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.systemFont(ofSize: 30)
        tableView.separatorStyle = .none
        tableView.backgroundView = messageLabel
    }
    
    private func setActivityIndicatorState(isShowing: Bool) {
        if isShowing {
            spinner.addToAndFill(parent: spinnerView)
            spinner.startAnimating()
            UIView.transition(
                with: view,
                duration: 0.33,
                options: .transitionCrossDissolve,
                animations: {
                    self.spinnerView.addToParentAndFillChild(parent: self.view, child: self.tableView)
            },
                completion: nil)
            return
        }
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        UIView.transition(
            with: view,
            duration: 0.33,
            options: .transitionCrossDissolve,
            animations: {
                self.spinnerView.removeFromSuperview()
        },
            completion: nil)
    }
    
    private func reloadTableData() {
        tableView.separatorStyle = .singleLine
        tableView.reloadData()
    }
    
    private func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension UserSearchView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setNewQuery(query: searchText)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(executeNewSearch), object: nil)
        perform(#selector(executeNewSearch), with: nil, afterDelay: 0.5)
    }
}

extension UserSearchView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfUsers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserSearchTableCellView.reuseIdentifier, for: indexPath) as! UserSearchTableCellView
        let cellViewModel = viewModel.getUserViewModelAt(indexPath: indexPath)
        cell.setUp(viewModel: cellViewModel)
        viewModel.checkForNewPage(indexPath: indexPath)
        return cell
    }
}

extension UserSearchView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellViewModel = viewModel.getUserViewModelAt(indexPath: indexPath)
        cellViewModel.navigateToDetails(navigationController: navigationController)
    }
}
