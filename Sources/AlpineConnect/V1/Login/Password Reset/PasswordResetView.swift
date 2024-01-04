//
//  PasswordResetView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/13/22.
//

import SwiftUI
import AlpineUI

struct PasswordResetView: View {
    
    @StateObject var viewModel: PasswordResetViewModel
    
    @Binding var open: Bool
    
    init(open: Binding<Bool>) {
        self._open = open
        _viewModel = StateObject(wrappedValue: PasswordResetViewModel(open: open.wrappedValue))
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Enter your email to be sent a new temporary password.")
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                    .padding()
                    .frame(width: 100, alignment: .center)
                TextFieldBlock(title: "Email", value: $viewModel.email, required: true, changed: .constant(false))
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                SpinnerButton(label: "Reset Password", action: viewModel.reset, isDisabled: viewModel.email.isEmpty, activated: $viewModel.showSpinner)
            }
            .padding()
            .navigationTitle("User Password Reset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel", action: {open.toggle()})
                }
            }
            .onChange(of: viewModel.open) { value, _ in
                open = value
            }
            .alert(viewModel.alert().0, isPresented: $viewModel.showAlert, actions: {
                Button(viewModel.alert().2, action: viewModel.alert().3)
            }, message: {
                Text(viewModel.alert().1)
            })
        }
        .navigationViewStyle(.stack)
        .frame(width: 600, height: 260)
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView(open: .constant(true))
    }
}
