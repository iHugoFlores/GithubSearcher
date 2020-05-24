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
        return bar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView()
        table.estimatedRowHeight = 10
        table.rowHeight = UITableView.automaticDimension
        return table
    }()
    
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Github Searcher"
        view.backgroundColor = .white
        setUpViews()
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
        tableView.dataSource = self
        tableView.register(UserSearchTableCellView.self, forCellReuseIdentifier: UserSearchTableCellView.reuseIdentifier)
        tableView.addToAndFill(parent: view, belowOf: searchBar)
        displayOnTable(message: viewModel.noQueryMessage)
    }
    
    @objc private func executeNewSearch() {
        viewModel.getNewData()
    }
    
    private func displayOnTable(message: String?) {
        guard let message = message else {
            // tableView.separatorStyle = .singleLine
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
            spinnerView.addToParentAndFillChild(parent: view, child: tableView)
            spinner.startAnimating()
            return
        }
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        spinnerView.removeFromSuperview()
    }
    
    private func reloadTableData() {
        tableView.separatorStyle = .singleLine
        tableView.reloadData()
    }
}

extension UserSearchView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setNewQuery(query: searchText)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(executeNewSearch), object: nil)
        perform(#selector(executeNewSearch), with: nil, afterDelay: 0.4)
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
        return cell
    }
}
