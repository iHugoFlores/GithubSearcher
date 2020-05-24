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

    func addToAndFill(parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }

    func addToParentAndFillChild(parent: UIView, child: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        self.trailingAnchor.constraint(equalTo: child.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: child.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: child.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: child.bottomAnchor).isActive = true
    }
    
    func constraintTo(width: CGFloat, height: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true
    }
}
