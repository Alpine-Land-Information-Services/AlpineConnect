//
//  AlpineLoginView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import SwiftUI

public struct AlpineLoginView: View {
    
    @StateObject var viewModel: LoginViewModel

    @StateObject var authenticationViewModel = AuthenticationViewModel()
    @StateObject var alertViewModel = CustomAlertViewModel()

    @State private var showImportView = false
    @State var spinner = false
    
    public init(info: LoginConnectionInfo) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(info: info))
    }
    
    public var body: some View {
        VStack(alignment: .center) {
            VStack {
                Image(packageResource: "SPI-Logo", ofType: ".png").resizable().aspectRatio(contentMode: .fit).frame(minWidth: 40, maxWidth: 200, minHeight: 50, maxHeight: 200, alignment: .center)
                Text("Sierra Pacific Industries").font(.title3)
                    .foregroundColor(Color.white)
                Text(viewModel.info.application).font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                VStack {
                    TextField("Username", text: $authenticationViewModel.userManager.userName)
                        .customTextField(padding: 10)
                        .frame(maxWidth: 400, minHeight: 40, alignment: .center)
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .cornerRadius(10).padding(.bottom, 5)

                    SecureField("Password", text: $authenticationViewModel.userManager.password)
                        .customTextField(padding: 10)
                        .frame(maxWidth: 400, minHeight: 40, alignment: .center)
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .cornerRadius(10).padding(.bottom, 15)
                    ZStack {
                        Button {
                            if !authenticationViewModel.userManager.password.isEmpty && !authenticationViewModel.userManager.userName.isEmpty {
                                spinner = true
                                loginButtonPressed()
                            } else {
                                alertViewModel.emptyFieldAlert()
                            }
                        } label: {
                            Text("Sign In").frame(width: 250, height: 60, alignment: .center)
                        }
                        .foregroundColor(spinner ? Color.accentColor : Color.white).font(.title)
                        .background(Color.accentColor).cornerRadius(15)
                        if spinner {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(height: 40)
                        }
                    }

                }
                .padding().background(Color.init(red: 0, green: 0, blue: 0, opacity: 0.75)).cornerRadius(20)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Image("Login-BG").resizable().ignoresSafeArea().blur(radius: 50, opaque: true).ignoresSafeArea())

            CustomAlertView()
                .environmentObject(alertViewModel)
                .environmentObject(authenticationViewModel)
        }
        .onAppear {
            authenticationViewModel.fetchCredentialsFromKeyChain()
            authenticationViewModel.handleBiometricAuthorization()
        }
    }
    
    private func loginButtonPressed() {
        authenticationViewModel.authenticateUser { response in
            self.handleAuthenticationResponse(_: response)
        }
    }
    
    private func handleAuthenticationResponse(_ response: LoginResponseMessage) {
        if response == .successfulLogin {
            if authenticationViewModel.areCredentialsSaved() {
                if authenticationViewModel.credentialsChanged() {
                    alertViewModel.updateAlertType(_: .updateKeychainAlert)
                    alertViewModel.updateShowAlertStatus(_: true)
                } else {
                    if authenticationViewModel.askForBioMetricAuthenticationSetup() {
                        alertViewModel.updateModelState(_: authenticationViewModel)
                    } else {
                        authenticationViewModel.updateSigninState(_: true, _: .online)
                    }
                }
            } else {
                alertViewModel.updateShowAlertStatus(_: true)
                alertViewModel.updateAlertType(_: .keychainAlert)
            }
        } else {
            DispatchQueue.main.async {
                spinner = false
                self.alertViewModel.loginResponse = response
                alertViewModel.updateShowAlertStatus(_: true)
                alertViewModel.updateAlertType(_: .authenticationAlert)
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
