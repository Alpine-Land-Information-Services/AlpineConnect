//
//  PasswordChangeView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/27/22.
//

import SwiftUI

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
                        Text(viewModel.userManager.userName)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    NewPassword(title: "Old Password", placeholder: "Enter old password", password: $viewModel.oldPassword)
                    Divider()
                        .frame(width: 60)
                    NewPassword(title: "New Password", placeholder: "Enter new password", password: $viewModel.newPassword)
                    Divider()
                        .frame(width: 60)
                    NewPassword(title: "New Password", placeholder: "Repeat new password", password: $viewModel.repeatedNewPassword)
                        .padding(.bottom, 20)
                    Divider()
                    SpinnerButton(label: "Change Password", action: viewModel.changePassword, isDisabled: viewModel.allFieldsFilled(), activated: $viewModel.showSpinner)
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
        .onChange(of: viewModel.dismiss) { _ in
            presentationMode.wrappedValue.dismiss()
        }
        .overlay {
            if viewModel.showSpinner {
                Color.black.opacity(0.50)
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(height: 40)
            }
        }
        .navigationViewStyle(.stack)
    }
    
//    var submit: some View {
//        Button {
//            viewModel.changePassword()
//        } label: {
//            Text("Change Password")
//                .font(.headline)
//                .padding()
//                .foregroundColor(Color.white)
//                .frame(maxWidth: .infinity)
//                .background(Color.accentColor)
//                .cornerRadius(10)
//                .padding()
//        }
//        .disabled(viewModel.allFieldsFilled())
//    }
    
    struct NewPassword: View {
        
        var title: String
        var placeholder: String
        
        @Binding var password: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(title):")
                    .font(.callout)
                SecureField(placeholder, text: $password)
                    .frame(maxWidth: .infinity, minHeight: 40, alignment: .center)
                    .foregroundColor(Color.black)
                    .cornerRadius(10)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
        }
    }
}

struct PasswordChangeView_Previews: PreviewProvider {
    
    static var previews: some View {
        PasswordChangeView(required: true)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
