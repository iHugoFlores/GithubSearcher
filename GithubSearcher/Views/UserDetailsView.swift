//
//  UserDetailsView.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class UserDetailsView: UIViewController {
    
    private var viewModel: UserDetailsViewModel!
    
    private let userImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.constraintTo(width: 120, height: 120)
        return image
    }()

    private let userDataLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let biograpgyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private let topContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 6
        view.distribution = .fillEqually
        view.alignment = .center
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }()

    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search for User's Repositories"
        bar.setContentHuggingPriority(.required, for: .vertical)
        return bar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.tableFooterView = UIView()
        table.estimatedRowHeight = 10
        table.rowHeight = UITableView.automaticDimension
        table.setContentCompressionResistancePriority(.required, for: .vertical)
        return table
    }()
    
    private let spinner = UIActivityIndicatorView(style: .large)
    
    private let spinnerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        return view
    }()

    init(viewModel: UserDetailsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        setUpDataBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpDataBinding() {
        viewModel.setActivityIndicatorHandler = setActivityIndicatorState
        viewModel.setScreenMessageHandler = displayOnTable
        viewModel.reloadTableHandler = reloadTableData
        viewModel.presentAlertHandler = displayAlert
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Github Searcher"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(onInfoPressed))
        setUpViews()
        setUpInitData()
    }
    
    @objc private func onInfoPressed() {
        viewModel.displayAPIInfo()
    }
    
    private func setUpViews() {
        topContainer.addAtTopOf(parent: view)
        topContainer.addArrangedSubview(userImage)
        topContainer.addArrangedSubview(userDataLabel)

        biograpgyLabel.addAtTopOf(parent: view, below: topContainer)
        
        setUpSearchBar()
        setUpTable()
    }
    
    private func setUpSearchBar() {
        searchBar.delegate = self
        searchBar.addAtTopOf(parent: view, below: biograpgyLabel)
    }
    
    private func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RepositoryTableCellView.self, forCellReuseIdentifier: RepositoryTableCellView.reuseIdentifier)
        tableView.addToAndFill(parent: view, belowOf: searchBar)
    }
    
    private func setUpInitData() {
        userImage.image = UIImage(data: viewModel.getUserAvatar())
        userDataLabel.attributedText = viewModel.getUserDescription()
        biograpgyLabel.text = viewModel.getUserBiography()
        displayOnTable(message: viewModel.getInitialScreenMessage())
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
        tableView.backgroundView = messageLabel
    }
    
    private func setActivityIndicatorState(isShowing: Bool) {
        if isShowing {
            spinner.addToAndCenter(parent: spinnerView)
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
        tableView.reloadData()
    }
    
    @objc private func executeNewSearch() {
        viewModel.getNewData()
    }
    
    private func onCellPressed(indexPath: IndexPath) {
        let repoViewModel = viewModel.getRepoViewModelAt(indexPath: indexPath)
        repoViewModel.navigateToWebRepo(navigationController: navigationController)
    }
    
    private func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension UserDetailsView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setNewQuery(query: searchText)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(executeNewSearch), object: nil)
        perform(#selector(executeNewSearch), with: nil, afterDelay: 0.4)
    }
}

extension UserDetailsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRepos()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableCellView.reuseIdentifier, for: indexPath) as! RepositoryTableCellView
        let repoViewModel = viewModel.getRepoViewModelAt(indexPath: indexPath)
        cell.setUp(viewModel: repoViewModel)
        viewModel.checkForNewPage(indexPath: indexPath)
        return cell
    }
}

extension UserDetailsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onCellPressed(indexPath: indexPath)
    }
}
