//
//  MainViewController.swift
//  Split
//
//  Created by Spencer Curtis on 9/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import WebKit

class MainViewController: ShiftableViewController {
    
    @IBOutlet weak var stackView: UIStackView!

    var topWebView: WebView!
    var bottomWebView: WebView!
    
    override func viewDidLoad() {
        
        topWebView = WebView(position: .top)
        bottomWebView = WebView(position: .bottom)
        
        stackView.addArrangedSubview(topWebView)
        stackView.addArrangedSubview(bottomWebView)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        stackView.axis = UIDevice.current.orientation.isPortrait ? .vertical : .horizontal
    }
}
