//
//  AlpineLoginView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import SwiftUI

public struct AlpineLoginView: View {
    
    @StateObject var viewModel: LoginViewModel
    
    @ObservedObject var loginAlert = LoginAlert.shared
    @ObservedObject var updater = SwiftUIUpdater()
    
    public init(info: LoginConnectionInfo) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(info: info))
    }
    
    public var body: some View {
        VStack {
            logo
                .modifier(UpdateCheckModifier(automatic: true))
            login
                .alert(isPresented: $loginAlert.showAlert) {
                    loginAlert.alert()
                }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Image("Login-BG").resizable().ignoresSafeArea().blur(radius: 50, opaque: true).ignoresSafeArea())
        .sheet(isPresented: $loginAlert.showSheet) {
            PasswordChangeView(required: true)
        }
        .onChange(of: loginAlert.showAlert) { show in
            if show {
                viewModel.spinner = false
            }
        }
    }
    
    var logo: some View {
        VStack {
            Image(packageResource: "SPI-Logo", ofType: ".png").resizable().aspectRatio(contentMode: .fit).frame(minWidth: 40, maxWidth: 200, minHeight: 50, maxHeight: 200, alignment: .center)
            Text("Sierra Pacific Industries")
                .font(.headline)
                .fontWeight(.thin)
                .foregroundColor(Color.white)
            Text(viewModel.info.application)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.white)
        }
    }
    
    var login: some View {
        VStack {
            TextField("Email", text: $viewModel.userManager.userName)
                .customTextField(padding: 10)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(.bottom, 5)
                .keyboardType(.emailAddress)
            SecureField("Password", text: $viewModel.userManager.inputPassword)
                .customTextField(padding: 10)
                .padding(.bottom, 15)
            ZStack {
                Button {
                    viewModel.loginButtonPressed()
                } label: {
                    Text("Sign In").frame(width: 250, height: 60, alignment: .center)
                }
                .foregroundColor(viewModel.spinner ? Color.accentColor : Color.white).font(.title)
                .background(Color.accentColor).cornerRadius(15)
                if viewModel.spinner {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(height: 40)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.75)).cornerRadius(20)
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//            .previewInterfaceOrientation(.portrait)
//    }
//}
