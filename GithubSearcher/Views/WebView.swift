//
//  WebView.swift
//  GithubSearcher
//
//  Created by Hugo Flores Perez on 5/25/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import UIKit
import WebKit

class WebView: UIViewController {
    
    private let webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        return webView
    }()
    
    private let spinner = UIActivityIndicatorView(style: .large)
    
    private let spinnerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        return view
    }()
    
    private var request: URLRequest!
    
    init(request: URLRequest) {
        super.init(nibName: nil, bundle: nil)
        self.request = request
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setUpViews()
    }
    
    private func setUpViews() {
        webView.navigationDelegate = self
        webView.addToAndFill(parent: view)
        webView.load(request)
        setUpLoader()
    }
    
    private func setUpLoader() {
        spinner.addToAndCenter(parent: spinnerView)
        spinner.startAnimating()
        spinnerView.addToAndFill(parent: view)
    }
    
    private func hideLoader() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        spinnerView.removeFromSuperview()
    }
}

extension WebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoader()
    }
}
