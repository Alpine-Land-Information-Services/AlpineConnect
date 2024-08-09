//
//  PasswordChangeView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/27/22.
//

import SwiftUI
import AlpineUI

struct PasswordChangeView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel: PasswordChangeViewModel
    
    init(required: Bool) {
        _viewModel = StateObject(wrappedValue: PasswordChangeViewModel(required: required))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Divider()
                    HStack {
                        Text("Account User:")
                            .font(.headline)
                            .fontWeight(.medium)
                        Text(UserManager.shared.userName)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .top, .trailing])
                    HStack {
                        CheckmarkBlock(text: "Reveal Password", checked: $viewModel.showPassword, changed: .constant(false), onEvent: { event, parameters in
                            Core.logUIEvent(event, parameters: parameters)
                        })
                        Divider()
                        Text("Password must be at least medium strength.")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    fields
                }
                .alert(viewModel.alert().0, isPresented: $viewModel.showAlert, actions: {
                    Button(viewModel.alert().1, action: viewModel.alert().3)
                }, message: {
                    Text(viewModel.alert().2)
                })
            }
            .navigationTitle("Password Change")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.dismiss.toggle()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
        .onChange(of: viewModel.dismiss) { _, _ in
            presentationMode.wrappedValue.dismiss()
        }
        .navigationViewStyle(.stack)
    }
    
    var fields: some View {
        VStack {
            PasswordField(title: "Old Password", placeholder: "Enter old password", password: $viewModel.oldPassword, showPassword: $viewModel.showPassword)
            Divider()
                .frame(width: 60)
            HStack {
                LabelBlock(value: "Password Strength")
                Text(viewModel.passwordStrenght)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            PasswordField(title: "New Password", placeholder: "Enter new password", password: $viewModel.newPassword, showPassword: $viewModel.showPassword)
            Divider()
                .frame(width: 60)
            PasswordField(title: "New Password", placeholder: "Repeat new password", password: $viewModel.repeatedNewPassword, showPassword: $viewModel.showPassword)
                .padding(.bottom)
            Divider()
            SpinnerButton(label: "Change Password", action: viewModel.changePassword, isDisabled: viewModel.allFieldsFilled(), activated: $viewModel.showSpinner)
        }
        .onChange(of: viewModel.newPassword) { _, pass in
            let str = viewModel.checkPasswordScore(password: pass)
            viewModel.passwordStrenght = viewModel.checkPassStr(str).0
        }
    }
    
    struct PasswordField: View {
        
        var title: String
        var placeholder: String
        
        @Binding var password: String
        @Binding var showPassword: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(title):")
                    .font(.footnote)
                Group {
                    if showPassword {
                        TextField(placeholder, text: $password)
                    }
                    else {
                        SecureField(placeholder, text: $password)
                    }
                }
                .frame(height: 24)
                .padding(6.0)
                .foregroundColor(Color(uiColor: .label))
                .overlay (
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color((password == "") ? UIColor.systemRed : UIColor.systemGray), lineWidth: (password == "") ? 1.2 : 0.2)
                )
                .background(Color(UIColor.systemGray6).opacity(0.5))
                .cornerRadius(5)
            }
            .padding()
        }
    }
}

struct PasswordChangeView_Previews: PreviewProvider {
    
    static var previews: some View {
        PasswordChangeView(required: true)
            .previewInterfaceOrientation(.landscapeRight)
    }
}
