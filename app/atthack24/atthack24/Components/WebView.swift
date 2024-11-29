//
//  WebView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {
    // 1
    let url: URL
    
    
    // 2
    func makeUIView(context: Context) -> WKWebView {
        
        return WKWebView()
    }
    
    // 3
    func updateUIView(_ webView: WKWebView, context: Context) {
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
