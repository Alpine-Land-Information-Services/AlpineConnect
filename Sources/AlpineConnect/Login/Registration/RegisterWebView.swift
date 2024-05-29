//
//  RegisterWebView.swift
//
//
//  Created by Vladislav on 5/17/24.
//

import SwiftUI
import WebKit
import AlpineUI
import AlpineCore

import SwiftUI


struct RegisterWebView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var showAlert: Bool
    
    @State private var isLoading = false
    @State private var registrationURL = URL(string: "https://alpinesupport-preview.azurewebsites.net/Account/Register/Webview")!

    var loginAlert = LoginAlert.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                WebViewRepresentable(isLoading: $isLoading, url: $registrationURL)
                if isLoading {
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Alpine Registration")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Dismiss")
                    }
                }
            }
        }
        .interactiveDismissDisabled(true)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: registrationURL) { newValue in
                loginAlert.updateAlertType(.customError(title: "Registration Successful", detail:  "You will receive an email shortly to confirm. \n\nNote:\nYou can only login after confirmation."))
                showAlert = true
                presentationMode.wrappedValue.dismiss()
            
        }
    }
}
