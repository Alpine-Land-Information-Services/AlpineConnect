//
//  WebViewRepresentable.swift
//  
//
//  Created by Vladislav on 5/20/24.
//

import SwiftUI
import WebKit

struct WebViewRepresentable: UIViewRepresentable {
   @Binding var isLoading: Bool
   @Binding var url: URL
   
   func makeCoordinator() -> Coordinator {
       Coordinator(self)
   }
   
   func makeUIView(context: Context) -> WKWebView {
       let webView = WKWebView()
       webView.navigationDelegate = context.coordinator
       webView.load(URLRequest(url: url))
       return webView
   }
   
   func updateUIView(_ webView: WKWebView, context: Context) {}
   
   class Coordinator: NSObject, WKNavigationDelegate {
       var parent: WebViewRepresentable
       
       init(_ parent: WebViewRepresentable) {
           self.parent = parent
       }
       
       func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           parent.isLoading = true
       }
       
       func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
           parent.isLoading = false
           if webView.url != parent.url {
               parent.url = webView.url ?? parent.url
           }
       }
       
       func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
           parent.isLoading = false
       }
   }
}
