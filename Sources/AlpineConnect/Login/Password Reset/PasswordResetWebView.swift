//
//  PasswordResetWebView.swift
//
//
//  Created by Vladislav on 5/20/24.
//

import SwiftUI

struct PasswordResetWebView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var showAlert: Bool
    
    @State private var isLoading = false
    @State private var resetURL = URL(string: "https://alpinesupport-preview.azurewebsites.net/account/forgotpassword/webview")!

    var loginAlert = LoginAlert.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                WebViewRepresentable(isLoading: $isLoading, url: $resetURL)
                if isLoading {
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Reset Password")
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
        .onChange(of: resetURL) { newValue in
                loginAlert.updateAlertType(.customError(title: "Reset Request Sent", detail:  "You will recieve an email shortly to confirm."))
                showAlert = true
                presentationMode.wrappedValue.dismiss()
        }
    }
}

