//
//  WebView.swift
//  Split
//
//  Created by Spencer Curtis on 9/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import WebKit

enum WebViewPosition: String {
    case top
    case bottom
}

class WebView: UIView, UITextFieldDelegate {
    
    var observation: NSKeyValueObservation?
    
    var position: WebViewPosition!
    
    var backButton: UIButton!
    var forwardButton: UIButton!
    var historyButton: UIButton!
    var buttonBar: UIView!
    var buttonBarStackView: UIStackView!
    var progressView: LinearProgressView!
    
    var searchField: UITextField!
    var searchFieldBar: UIView!
    
    var webView: WKWebView!
    
    var keyboardDismissRecognizer: UITapGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience init(position: WebViewPosition, frame: CGRect = .zero) {
        self.init(frame: frame)
        self.position = position
        let url = UserDefaults.standard.url(forKey: "\(position.rawValue)WebViewURL")
        loadURL(for: url?.absoluteString ?? "https://google.com")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        backButton = UIButton(type: .system)
        backButton.setTitle("←", for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        forwardButton = UIButton(type: .system)
        forwardButton.setTitle("→", for: .normal)
        forwardButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        
        historyButton = UIButton(type: .system)
        historyButton.setTitle("📖", for: .normal)
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        
        buttonBar = UIView()
        buttonBar.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(buttonBar)
        
        buttonBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        buttonBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        buttonBar.heightAnchor.constraint(equalToConstant: 30).isActive = true
        buttonBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        buttonBarStackView = UIStackView()
        buttonBarStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonBarStackView.addArrangedSubview(backButton)
        buttonBarStackView.addArrangedSubview(forwardButton)
        buttonBarStackView.addArrangedSubview(historyButton)
        buttonBarStackView.axis = .horizontal
        buttonBarStackView.alignment = .center
        buttonBarStackView.distribution = .fillEqually
        
        buttonBar.addSubview(buttonBarStackView)
        
        buttonBarStackView.leadingAnchor.constraint(equalTo: buttonBar.leadingAnchor).isActive = true
        buttonBarStackView.trailingAnchor.constraint(equalTo: buttonBar.trailingAnchor).isActive = true
        buttonBarStackView.topAnchor.constraint(equalTo: buttonBar.topAnchor).isActive = true
        buttonBarStackView.bottomAnchor.constraint(equalTo: buttonBar.bottomAnchor).isActive = true
        
        searchField = UITextField()
        searchField.clearButtonMode = .always
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.returnKeyType = .go
        searchField.placeholder = "Enter a website:"
        searchField.delegate = self
        searchField.autocorrectionType = .no
        searchField.autocapitalizationType = .none
        
        searchFieldBar = UIView()
//        searchFieldBar.backgroundColor = .red
        searchFieldBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(searchFieldBar)
        
        searchFieldBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        searchFieldBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        searchFieldBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        searchFieldBar.heightAnchor.constraint(equalToConstant: 30).isActive = true
        searchFieldBar.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)

        searchFieldBar.addSubview(searchField)

        searchField.leadingAnchor.constraint(equalTo: searchFieldBar.leadingAnchor, constant: 20).isActive = true
        searchField.trailingAnchor.constraint(equalTo: searchFieldBar.trailingAnchor, constant: -20).isActive = true
        searchField.topAnchor.constraint(equalTo: searchFieldBar.topAnchor).isActive = true
        searchField.bottomAnchor.constraint(equalTo: searchFieldBar.bottomAnchor).isActive = true
        
        webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(webView)
        
        webView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: searchFieldBar.bottomAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: buttonBar.topAnchor).isActive = true
        
        progressView = LinearProgressView()
        progressView.webView = webView
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(progressView)
        
        progressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: searchFieldBar.bottomAnchor).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        
        keyboardDismissRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        webView.addGestureRecognizer(keyboardDismissRecognizer)
        
        observation = webView.observe(\.url) { (_, _) in
            self.searchField.text = self.webView.url?.absoluteString ?? ""
            UserDefaults.standard.set(self.webView.url, forKey: "\(self.position.rawValue)WebViewURL")
        }
    }
    
    @objc func dismissKeyboard() {
        endEditing(true)
    }
    
    func loadURL(for urlString: String) {
        
        var components = URLComponents(string: urlString)
        
        let scheme = components?.scheme
        
        components?.scheme = scheme ?? "https"
        
        guard let url = components?.url else { return }
        
        let request = URLRequest(url: url)
        
        webView.load(request)
        
        dismissKeyboard()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return true }
        
        loadURL(for: text)
        
        return true
    }
    
    @objc func goBack() {
        guard webView.canGoBack else { return }
        
        webView.goBack()
        
        backButton.isEnabled = webView.canGoBack
    }
    
    @objc func goForward() {
        
        guard webView.canGoForward else { return }
    
        webView.goForward()
        
        forwardButton.isEnabled = webView.canGoForward
    }
}
