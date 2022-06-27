//
//  LoginAlertViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import SwiftUI

final class LoginAlert {
    
    var activeAlert: AlertType = .authenticationAlert
    var loginResponse: LoginResponseMessage?
    var showAlertMessage: Bool = false
    
    var authenthication = KeychainAuthentication.shared
    var supportedBioAuthType: String? = nil

    var alertTitle: String {
        if activeAlert == .biometricAuthAlert {
            return "Set up biometric authentication?"
        } else if activeAlert == .updateKeychainAlert {
            return "Update stored login credentials in memory?"
        } else {
            return "Save login credentials?"
        }
    }

    var alertMessage: String {
        if activeAlert == .biometricAuthAlert {
            return "Your device supports \(supportedBioAuthType ?? "") sign in. You can enable this to expedite future sign in."
        } else if  activeAlert == .updateKeychainAlert {
            return "Update your stored credentials with the latest login credentials."
        } else {
            return "This will expedite future login."
        }
    }
    
    func emptyFieldAlert() {
        self.showAlertMessage = true
        activeAlert = .emptyFields
    }

    func updateShowAlertStatus(_ showingAlert: Bool) {
        self.showAlertMessage = showingAlert

    }

    func updateAlertType(_ alertType: AlertType) {
        self.activeAlert = alertType
    }

    func updateSupportedBioAuthType(_ type: String?) {
        self.supportedBioAuthType = type
    }

    func updateModelState(_ authenthication: KeychainAuthentication){
        updateSupportedBioAuthType(_: authenthication.supportBiometricAuthType)
        supportedBioAuthType = authenthication.supportBiometricAuthType
        updateShowAlertStatus(_: true)
        updateAlertType(_: .biometricAuthAlert)
    }
    
    func alert() -> Alert {
        switch activeAlert {
        case .authenticationAlert:
            if loginResponse != .successfulLogin {
                return Alert(title: Text(loginResponse?.rawValue.0 ?? ""), message: Text(loginResponse?.rawValue.1 ?? ""), dismissButton: .default(Text("Okay"), action: {
                    self.updateShowAlertStatus(_: false)
                    return;
                }))
            } else {
                return Alert(title: Text(""))
            }
        case .emptyFields:
            return Alert(title: Text("Empty Fields"), message: Text("All login fields must be filled."), dismissButton: .default(Text("Try Again"), action: {
                self.updateShowAlertStatus(_: false)
                return;
            }))
        case .biometricAuthAlert:
            return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Set Up"), action: {
                self.authenthication.setupBioMetricAuthentication { result in
                    self.authenthication.updateSigninState(_: true, _: .online)
                }
            }), secondaryButton: .default(Text("Not now"), action: {
                self.authenthication.saveBiometricAuthRequestTimeInUserDefault()
                self.authenthication.updateSigninState(_: true, _: .online)
            }))
        case .keychainAlert:
            return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Yes"), action: {
                self.authenthication.saveCredentialsToKeyChain()
                self.updateShowAlertStatus(_: false)
                if self.authenthication.askForBioMetricAuthenticationSetup() {
                    self.updateSupportedBioAuthType(_: self.authenthication.supportBiometricAuthType)
                    self.updateShowAlertStatus(_: true)
                    self.updateAlertType(_: .biometricAuthAlert)
                } else {
                    self.authenthication.updateSigninState(_: true, _: .online)
                }
            }), secondaryButton: .default(Text("No"), action: {
                self.authenthication.updateSigninState(_: true, _: .online)
            }))

        case .updateKeychainAlert:
            return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Update"), action: {
                self.authenthication.updateCredentialsOnKeyChain { _ in
                    if self.authenthication.askForBioMetricAuthenticationSetup() {
                        self.updateSupportedBioAuthType(_: self.authenthication.supportBiometricAuthType)
                        self.updateShowAlertStatus(_: true)
                        self.updateAlertType(_: .biometricAuthAlert)
                    } else {
                        self.authenthication.updateSigninState(_: true, _: .online)
                    }
                }
            }), secondaryButton: .default(Text("Not now"), action: {
                self.authenthication.updateSigninState(_: true, _: .online)
            }))
        }
    }
}

enum AlertType {
    case authenticationAlert
    case emptyFields
    case keychainAlert
    case biometricAuthAlert
    case updateKeychainAlert
}
