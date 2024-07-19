//
//  RegistrationWebView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/5/24.
//

import SwiftUI
import AlpineUI
import AlpineCore

struct RegistrationWebView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var registrationURL = URL(string: "https://alpinesupport-preview.azurewebsites.net/Account/Register/Webview")!
    
    var body: some View {
        NavigationStack {
            WebView(url: $registrationURL)
                .navigationTitle("Alpine Registration")
                .toolbar {
                    DismissButton()
                }
        }
        .interactiveDismissDisabled()
        .onChange(of: registrationURL) { oldValue, newValue in
            dismiss()
            Core.makeSimpleAlert(title: "Registration Successful", message: "You will recieve an email shortly to confirm. \n\nNote:\nYou can only login after confirmation.")
        }
    }
}
