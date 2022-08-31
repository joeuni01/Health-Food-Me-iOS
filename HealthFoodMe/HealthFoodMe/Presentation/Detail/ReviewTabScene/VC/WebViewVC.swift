//
//  WebViewVC.swift
//  HealthFoodMe
//
//  Created by 강윤서 on 2022/09/01.
//

import UIKit
import WebKit

class WebViewVC: UIViewController {
    
    // MARK: - Properties
    
    private var url = URL(string: "")
    
    // MARK: - UI Components
    
    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        webView.load(URLRequest(url: url!))
    }
    
    override func viewDidLayoutSubviews() {
        webView.frame = view.bounds
    }
}

// MARK: - Extensions

extension WebViewVC {
    private func setUI() {
        view.addSubviews(webView)
    }
}
