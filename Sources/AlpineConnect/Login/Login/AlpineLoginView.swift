//
//  AlpineLoginView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import SwiftUI
import AlpineUI

public struct AlpineLoginView: View {
    
    @StateObject var viewModel: LoginViewModel
    
    @ObservedObject var loginAlert = LoginAlert.shared
    @ObservedObject var networkMonitor = NetworkMonitor.shared
    @ObservedObject var updater = SwiftUIUpdater()
    
    let updateStatus = NotificationCenter.default.publisher(for: NSNotification.Name("UpdateStatus"))
    
    public init(info: LoginConnectionInfo) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(info: info))
    }
    
    public var body: some View {
        VStack {
            logo
                .modifier(UpdateCheckModifier(automatic: true, dismissAction: viewModel.bioAuthentication, DBPassword: viewModel.info.connectDBPassword))
                .sheet(isPresented: $loginAlert.showSheet) {
                    switch loginAlert.activeAlert {
                    case .registrationRequired:
                        RegisterView(open: $loginAlert.showSheet)
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
                .alert(loginAlert.newAlert().title, isPresented: $loginAlert.showNewAlert) {
                    loginAlert.newAlert().buttons
                } message: {
                    Text(loginAlert.newAlert().message)
                }
                .sheet(isPresented: $viewModel.register) {
                    RegisterView(open: $viewModel.register)
                }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Image("Login-BG").resizable().blur(radius: 50, opaque: true).ignoresSafeArea())
        .overlay {
            HStack {
                Text("Version: \(Tracker.appVersion())")
                    .fontWeight(.medium)
                Text("Build: \(Tracker.appBuild())")
                    .fontWeight(.medium)
            }
            .font(.caption)
            .foregroundColor(Color.gray)
            .padding(6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .ignoresSafeArea(.keyboard, edges: .all)
        }
        .resizableSheet(isPresented: $viewModel.showResetPassword) {
            PasswordResetView(open: $viewModel.showResetPassword)
        }
        .onChange(of: loginAlert.showAlert) { show in
            if show {
                viewModel.spinner = false
            }
        }
        .onChange(of: loginAlert.showNewAlert) { show in
            if show {
                viewModel.spinner = false
            }
        }
        .onReceive(updateStatus) { _ in
            viewModel.bioAuthentication()
        }
        .onDisappear {
            viewModel.userManager.inputPassword = ""
        }
    }
    
    var logo: some View {
        VStack {
            Image(packageResource: "SPI-Logo", ofType: ".png").resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: 200, alignment: .center)
            Text("Sierra Pacific Industries")
                .font(.headline)
                .fontWeight(.thin)
                .foregroundColor(Color.white)
            Text(viewModel.info.appFullName)
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
            passwordField
                .loginField(placeholder: "Password", value: $viewModel.userManager.inputPassword)
            ZStack {
                Button {
                    viewModel.loginButtonPressed()
                } label: {
                    Text("Sign In")
                        .frame(width: 250, height: 60, alignment: .center)
                }
                .foregroundColor(viewModel.spinner ? Color.accentColor : Color.white).font(.title)
                .background(Color.accentColor).cornerRadius(15)
                if viewModel.spinner {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(height: 40)
                }
            }
            .padding(6)
            HStack {
                Button("Register", action: {viewModel.register.toggle()})
                Divider()
                    .frame(height: 20, alignment: .center)
                Button("Forgot Password?", action: {viewModel.showResetPassword.toggle()})
            }
            .padding(.bottom, 8)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .center)
            .disabled(!networkMonitor.connected)
        }
        .padding([.leading, .top, .trailing])
        .background(Color.black.opacity(0.75)).cornerRadius(20)
        .frame(maxWidth: 400, alignment: .center)
    }
    
    var passwordField: some View {
        
        SecureField("", text: $viewModel.userManager.inputPassword)
            .overlay {
                Group {
                    if viewModel.showBioIcon {
                        Button {
                            viewModel.bioClickAuthentication()
                        } label: {
                            Image(systemName: viewModel.authenthication.supportBiometricAuthType == .faceID ? "faceid" : "touchid")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 15)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//            .previewInterfaceOrientation(.portrait)
//    }
//}
