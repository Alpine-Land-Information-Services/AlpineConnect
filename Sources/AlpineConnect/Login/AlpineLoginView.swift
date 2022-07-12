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
                .modifier(UpdateCheckModifier(automatic: true, DBPassword: viewModel.info.connectDBPassword))
                .sheet(isPresented: $loginAlert.showSheet) {
                    switch loginAlert.activeAlert {
                    case .registrationRequired:
                        RegisterView(open: $loginAlert.showSheet, isRegistration: true)
                    case .infoChangeRequired:
                        RegisterView(open: $loginAlert.showSheet, isRegistration: false)
                    case .passwordChangeRequired:
                        PasswordChangeView(required: true)
                    default:
                        EmptyView()
                    }
                }
            login
                .alert(isPresented: $loginAlert.showAlert) {
                    loginAlert.alert()
                }
                .sheet(isPresented: $viewModel.register) {
                    RegisterView(open: $viewModel.register, isRegistration: true)
                }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Image("Login-BG").resizable().ignoresSafeArea().blur(radius: 50, opaque: true).ignoresSafeArea())
        .onChange(of: loginAlert.showAlert) { show in
            if show {
                viewModel.spinner = false
            }
        }
        .onDisappear {
            viewModel.userManager.inputPassword = ""
        }
//        .task {
//            do {
//                try await Register.register(info: Register.RegistrationInfo(email: "jlebid@alpine-lis.com", firstName: "Test", lastName: "Test"))
//            }
//            catch {
//                fatalError()
//            }
//        }
    }
    
    var logo: some View {
        VStack {
                Image(packageResource: "SPI-Logo", ofType: ".png").resizable().aspectRatio(contentMode: .fit).frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: 200, alignment: .center)
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
            TextField("", text: $viewModel.userManager.userName)
                .loginField(placeholder: "Email", value: $viewModel.userManager.userName)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.bottom, 4)
            SecureField("", text: $viewModel.userManager.inputPassword)
                .loginField(placeholder: "Password", value: $viewModel.userManager.inputPassword)
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
            .padding(6)
            Divider()
                .foregroundColor(Color.white)
                .frame(width: 100)
            Button {
                viewModel.register.toggle()
            } label: {
                Text("Register")
                    .font(.callout)
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
