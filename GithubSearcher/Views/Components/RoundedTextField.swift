//
//  RoundedTextField.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/26/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit

class RoundedTextField: UITextField {
    
    var padding = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 24)
    
    init() {
        super.init(frame: .zero)
        applyCustomStyle()
    }
    
    private func applyCustomStyle() {
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.clearButtonMode = .always
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
