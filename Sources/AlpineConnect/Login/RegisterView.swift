//
//  RegisterView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/7/22.
//

import SwiftUI
import AlpineUI

struct RegisterView: View {
    
    @StateObject var viewModel: RegisterViewModel
    
    @Binding var show: Bool
    
    init(show: Binding<Bool>) {
        self._show = show
        _viewModel = StateObject(wrappedValue: RegisterViewModel())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    Text("Enter your name and company email address to be sent a one time password for login.")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                        .padding()
                    HStack {
                        TextFieldBlock(title: "First Name", value: $viewModel.firstName, required: true, changed: .constant(false))
                        TextFieldBlock(title: "Last Name", value: $viewModel.lastName, required: true, changed: .constant(false))
                    }
                    Divider()
                        .padding()
                        .frame(width: 100, alignment: .center)
                    TextFieldBlock(title: "Email", value: $viewModel.email, required: true, changed: .constant(false))
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    Spacer()
                    submit
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            show.toggle()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
                .navigationTitle("Register")
                .background(Color.init(uiColor: .systemBackground))
            }
        }
        .alert("Invalid Email", isPresented: $viewModel.alert, actions: { Button("Try Again") {} }, message: {
            Text("You entered an invalid email.")
        })
    }
    
    var submit: some View {
        Button {
            viewModel.submit()
        } label: {
            Text("Send")
                .font(.headline)
                .padding()
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .cornerRadius(10)
                .padding()
        }
        .disabled(viewModel.submitEnabled())
    }
    
    struct SecurityQuestion: View {
        
        var number: String
        var values: [[String]]
        
        @Binding var selection: String
        @Binding var answer: String
        
        var body: some View {
            SingleDropdownBlock(title: "Security Question \(number)", values: values, selection: $selection, required: true, changed: .constant(false))
            TextFieldBlock(title: "Security Answer \(number)", value: $answer, required: true, changed: .constant(false))
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(show: .constant(true))
    }
}
