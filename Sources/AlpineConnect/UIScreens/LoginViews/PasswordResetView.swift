//
//  PasswordResetView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/5/24.
//

import SwiftUI

import AlpineUI
import AlpineCore

struct PasswordResetView: View {
        
    @State private var resetURL = URL(string: "https://alpinesupport-preview.azurewebsites.net/account/forgotpassword/webview")!
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            WebView(url: $resetURL)
                .navigationTitle("Password Reset")
                .toolbar {
                    DismissButton(onEvent: { event, parameters in
                        Core.logUIEvent(event, parameters: parameters)
                    })
                }
        }
        .interactiveDismissDisabled()
        .onChange(of: resetURL) { oldValue, newValue in
            dismiss()
            Core.makeSimpleAlert(title: "Reset Request Sent", message: "You will recieve an email shortly to confirm.")
        }
    }
}
