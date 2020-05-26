//
//  SpinnerView.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/26/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class SpinnerView: UIView {

    private let spinner = UIActivityIndicatorView(style: .large)
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 0, alpha: 0.3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentOn(parent: UIView) {
        spinner.addToAndCenter(parent: self)
        spinner.startAnimating()
        UIView.transition(
            with: parent,
            duration: 0.33,
            options: .transitionCrossDissolve,
            animations: {
                self.addToAndFill(parent: parent)
        },
            completion: nil)
    }
    
    func stop() {
        guard let superview = superview else { return }
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        UIView.transition(
            with: superview,
            duration: 0.33,
            options: .transitionCrossDissolve,
            animations: {
                self.removeFromSuperview()
        },
            completion: nil)
        spinner.stopAnimating()
    }
}
