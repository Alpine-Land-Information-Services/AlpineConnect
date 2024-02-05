//
//  RegistrationView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/5/24.
//

import SwiftUI

import AlpineUI
import AlpineCore

struct RegistationView: View {
    
    @State private var registrationURL = URL(string: "https://alpinesupport-preview.azurewebsites.net/account/register/webview")!
    @Environment(\.dismiss) var dismiss
    
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
