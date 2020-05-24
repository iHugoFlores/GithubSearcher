//
//  UIView+Ext.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

extension UIView {
    func addAtTopOf(parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parent.safeAreaLayoutGuide.topAnchor).isActive = true
    }

    func addToAndFill(parent: UIView, belowOf reference: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: reference.bottomAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }
}
