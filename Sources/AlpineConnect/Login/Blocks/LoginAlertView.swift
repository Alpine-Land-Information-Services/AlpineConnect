//
//  LoginAlertView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import SwiftUI

struct CustomAlertView: View {
    
    @EnvironmentObject var loginViewModel: AuthenticationViewModel
    @EnvironmentObject var alertViewModel: CustomAlertViewModel

    var body: some View {
        VStack {
            
        }
        .alert(isPresented: $alertViewModel.showAlertMessage) {
            switch alertViewModel.activeAlert {
            case .authenticationAlert:
                if alertViewModel.loginResponse != .successfulLogin {
                    return Alert(title: Text(alertViewModel.loginResponse?.rawValue.0 ?? ""), message: Text(alertViewModel.loginResponse?.rawValue.1 ?? ""), dismissButton: .default(Text("Okay"), action: {
                        alertViewModel.updateShowAlertStatus(_: false)
                        return;
                    }))
                } else {
                    return Alert(title: Text(""))
                }
            case .emptyFields:
                return Alert(title: Text("Empty Fields"), message: Text("All login fields must be filled."), dismissButton: .default(Text("Try Again"), action: {
                    alertViewModel.updateShowAlertStatus(_: false)
                    return;
                }))
            case .biometricAuthAlert:
                return Alert(title: Text(alertViewModel.alertTitle), message: Text(alertViewModel.alertMessage), primaryButton: .default(Text("Setup"), action: {
                    loginViewModel.setupBioMetricAuthentication { result in
                        loginViewModel.updateSigninState(_: true, _: .online)
                    }
                }), secondaryButton: .default(Text("Not now"), action: {
                    self.loginViewModel.saveBiometricAuthRequestTimeInUserDefault()
                    loginViewModel.updateSigninState(_: true, _: .online)
                }))
            case .keychainAlert:
                return Alert(title: Text(alertViewModel.alertTitle), message: Text(alertViewModel.alertMessage), primaryButton: .default(Text("Yes"), action: {
                    loginViewModel.saveCredentialsToKeyChain()
                    alertViewModel.updateShowAlertStatus(_: false)
                    if loginViewModel.askForBioMetricAuthenticationSetup() {
                        alertViewModel.updateSupportedBioAuthType(_: loginViewModel.supportBiometricAuthType)
                        alertViewModel.updateShowAlertStatus(_: true)
                        alertViewModel.updateAlertType(_: .biometricAuthAlert)
                    } else {
                        loginViewModel.updateSigninState(_: true, _: .online)
                    }
                }), secondaryButton: .default(Text("No"), action: {
                    loginViewModel.updateSigninState(_: true, _: .online)
                }))

            case .updateKeychainAlert:
                return Alert(title: Text(alertViewModel.alertTitle), message: Text(alertViewModel.alertMessage), primaryButton: .default(Text("Update"), action: {
                    loginViewModel.updateCredentialsOnKeyChain { _ in
                        if loginViewModel.askForBioMetricAuthenticationSetup() {
                            alertViewModel.updateSupportedBioAuthType(_: loginViewModel.supportBiometricAuthType)
                            alertViewModel.updateShowAlertStatus(_: true)
                            alertViewModel.updateAlertType(_: .biometricAuthAlert)
                        } else {
                            loginViewModel.updateSigninState(_: true, _: .online)
                        }
                    }
                }), secondaryButton: .default(Text("Not now"), action: {
                    loginViewModel.updateSigninState(_: true, _: .online)
                }))
            }
        }
    }
}
