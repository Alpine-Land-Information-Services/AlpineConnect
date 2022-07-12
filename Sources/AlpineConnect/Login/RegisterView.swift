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
    
    @Binding var open: Bool
    
    var isRegistration: Bool
    
    init(open: Binding<Bool>, isRegistration: Bool) {
        self._open = open
        self.isRegistration = isRegistration
        _viewModel = StateObject(wrappedValue: RegisterViewModel(open: open.wrappedValue))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    Text(isRegistration ? "Fill out the registration form to be sent a temporary password for login." : "Fill out the form to update you user account information.")
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
                    Divider()
                        .padding()
                        .frame(width: 100, alignment: .center)
                    TextFieldBlock(title: "Confirm Email", value: $viewModel.confirmEmail, required: true, changed: .constant(false))
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(.bottom, 20)
                    Divider()
                        .padding()
                    submit
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.open.toggle()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
                .navigationTitle(isRegistration ? "User Registration" : "User Information Update")
                .background(Color.init(uiColor: .systemBackground))
                .onChange(of: viewModel.open) { value in
                    open = value
                }
            }
        }
        .alert(viewModel.alert().0, isPresented: $viewModel.showAlert, actions: { Button {
            viewModel.alert().3()
        } label: {
            Text(viewModel.alert().2)
        }}, message: {
            Text(viewModel.alert().1)
        })
    }
    
    var submit: some View {
        Button {
            viewModel.submit(existingDBUser: !isRegistration)
        } label: {
            Text(isRegistration ? "Register" : "Update")
                .font(.headline)
                .padding()
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .cornerRadius(10)
                .padding()
        }
        .disabled(viewModel.checkMissingRequirements())
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
        RegisterView(open: .constant(true), isRegistration: false)
    }
}
