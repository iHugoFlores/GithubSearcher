//
//  UserSearchView.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/23/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class UserSearchView: UIViewController {
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search for Users"
        return bar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()

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
        searchBar.addAtTopOf(parent: view)
    }
    
    private func setUpTable() {
        tableView.addToAndFill(parent: view, belowOf: searchBar)
    }
}
