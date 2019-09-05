//
//  LinearProgressView.swift
//  Split
//
//  Created by Spencer Curtis on 9/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import WebKit

class LinearProgressView: UIView {
    
    let color = UIColor(red: 30.0/255.0, green: 160.0/255.0, blue: 242.0/255.0, alpha: 1.0).cgColor

    weak var webView: WKWebView! {
        didSet {
            observation = webView.observe(\.estimatedProgress, changeHandler: { (webView, change) in
                self.setNeedsDisplay()
            })
        }
    }
    
    var observation: NSKeyValueObservation?
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        guard webView.estimatedProgress != 1.0 else {
            UIColor.clear.set()
            UIRectFill(rect)
            return
        }
        
        let newRect = CGRect(x: 0, y: 0, width: rect.width * CGFloat(webView.estimatedProgress), height: rect.height)
        
        let bezier = UIBezierPath(roundedRect: newRect, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 8, height: 8))
        
        context.setFillColor(color)
        
        bezier.fill()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
}
