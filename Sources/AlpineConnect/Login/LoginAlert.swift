//
//  LoginAlertViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import SwiftUI

class LoginAlert: ObservableObject {
    
    static let shared = LoginAlert()
    
    @Published var showAlert = false
    @Published var showSheet = false
    
    var activeAlert: AlertType = .authenticationAlert
    var loginResponse: LoginResponseMessage?
    
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
    
    func updateAlertType(_ alertType: AlertType) {
        showAlert.toggle()
        self.activeAlert = alertType
    }
    
    func updateSupportedBioAuthType(_ type: String?) {
        self.supportedBioAuthType = type
    }
    
    func updateModelState(_ authenthication: KeychainAuthentication){
        updateSupportedBioAuthType(_: authenthication.supportBiometricAuthType)
        supportedBioAuthType = authenthication.supportBiometricAuthType
        updateAlertType(_: .biometricAuthAlert)
    }
    
    func alert() -> Alert {
        switch activeAlert {
        case .authenticationAlert:
            if loginResponse != .successfulLogin {
                return Alert(title: Text(loginResponse?.rawValue.0 ?? ""), message: Text(loginResponse?.rawValue.1 ?? ""), dismissButton: .default(Text("Okay"), action: {
                    return;
                }))
            } else {
                return Alert(title: Text(""))
            }
        case .emptyFields:
            return Alert(title: Text("Empty Fields"), message: Text("All login fields must be filled."), dismissButton: .default(Text("Try Again"), action: {
                return;
            }))
        case .biometricAuthAlert:
            return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Set Up"), action: {
                self.authenthication.setupBioMetricAuthentication { result in
                    self.authenthication.saveCredentialsToKeyChain()
                    self.authenthication.updateSigninState(true)
                }
            }), secondaryButton: .default(Text("Not now"), action: {
                self.authenthication.saveBiometricAuthRequestTimeInUserDefault()
                self.authenthication.updateSigninState(true)
            }))
        case .keychainAlert:
            return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Yes"), action: {
                self.authenthication.saveCredentialsToKeyChain()
                self.authenthication.updateSigninState(true)
            }), secondaryButton: .default(Text("No"), action: {
                self.authenthication.updateSigninState(true)
            }))
            
        case .updateKeychainAlert:
            return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Update"), action: {
                self.authenthication.updateCredentialsOnKeyChain { _ in
                    if self.authenthication.askForBioMetricAuthenticationSetup() {
                        self.updateSupportedBioAuthType(_: self.authenthication.supportBiometricAuthType)
                        self.updateAlertType(_: .biometricAuthAlert)
                    } else {
                        self.authenthication.updateSigninState(true)
                    }
                }
            }), secondaryButton: .default(Text("Not now"), action: {
                self.authenthication.updateSigninState(true)
            }))
        case .updatePassword:
            return Alert(title: Text("Change Password"),
                         message: Text("In order to login, your account requires a password change."),
                         dismissButton: .default(Text("Change Now"), action: {self.showSheet.toggle()}))
        case .inactiveUser:
            return Alert(title: Text("Unauthorized Access"),
                         message: Text("Your account does not have access to this application. Contact administator for more information."),
                         dismissButton: .default(Text("OK"), action: {}))
        }
    }
}

enum AlertType {
    case authenticationAlert
    case emptyFields
    case keychainAlert
    case biometricAuthAlert
    case updateKeychainAlert
    case updatePassword
    case inactiveUser
}
