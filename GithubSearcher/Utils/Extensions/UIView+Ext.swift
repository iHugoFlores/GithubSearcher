//
//  UIView+Ext.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/24/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

extension UIView {
    private func addToParentAndActivateAutolayout(parent: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
    }

    func addAtTopOf(parent: UIView) {
        addToParentAndActivateAutolayout(parent: parent)
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parent.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    func addAtTopOf(parent: UIView, below: UIView) {
        addToParentAndActivateAutolayout(parent: parent)
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: below.bottomAnchor).isActive = true
    }

    func addToAndFill(parent: UIView, belowOf reference: UIView) {
        addToParentAndActivateAutolayout(parent: parent)
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: reference.bottomAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }

    func addToAndFill(parent: UIView) {
        addToParentAndActivateAutolayout(parent: parent)
        self.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }

    func addToParentAndFillChild(parent: UIView, child: UIView) {
        addToParentAndActivateAutolayout(parent: parent)
        self.trailingAnchor.constraint(equalTo: child.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: child.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: child.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: child.bottomAnchor).isActive = true
    }
    
    func constraintTo(width: CGFloat, height: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: width)
        widthConstraint.priority = UILayoutPriority(999)
        widthConstraint.isActive = true
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true
    }
    
    func addToAndCenter(parent: UIView) {
        addToParentAndActivateAutolayout(parent: parent)
        self.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        self.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
    }
}
