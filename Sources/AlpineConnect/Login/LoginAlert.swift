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
    
    var activeAlert: LoginResponseMessage = .noAccess
    var loginResponse: LoginResponseMessage?
    
    var authenthication = KeychainAuthentication.shared
    var supportedBioAuthType: String? = nil
    
    var alertTitle: String {
        if activeAlert == .enableBiometricsAlert {
            return "Set up biometric authentication?"
        } else if activeAlert == .updateKeychainAlert {
            return "Update stored login credentials in memory?"
        } else {
            return "Save login credentials?"
        }
    }
    
    var alertMessage: String {
        if activeAlert == .enableBiometricsAlert {
            return "Your device supports \(supportedBioAuthType ?? "") sign in. You can enable this to expedite future sign in."
        } else if  activeAlert == .updateKeychainAlert {
            return "Update your stored credentials with the latest login credentials."
        } else {
            return "This will expedite future login."
        }
    }
    
    func updateAlertType(_ alertType: LoginResponseMessage) {
        DispatchQueue.main.async {
            self.showAlert.toggle()
        }
        self.activeAlert = alertType
    }
    
    func updateSupportedBioAuthType(_ type: String?) {
        self.supportedBioAuthType = type
    }
    
    func updateModelState(_ authenthication: KeychainAuthentication) {
        updateSupportedBioAuthType(_: authenthication.supportBiometricAuthType)
        supportedBioAuthType = authenthication.supportBiometricAuthType
        updateAlertType(_: .enableBiometricsAlert)
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
        case .enableBiometricsAlert:
            return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Set Up"), action: {
                self.authenthication.setupBioMetricAuthentication { result in
                    self.authenthication.saveCredentialsToKeyChain()
                    self.authenthication.updateSigninState(true)
                }
            }), secondaryButton: .default(Text("Not now"), action: {
                self.authenthication.updateSigninState(true)
            }))
        case .updateKeychainAlert:
            return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Update"), action: {
                self.authenthication.updateCredentialsOnKeyChain { _ in
                    if self.authenthication.askForBioMetricAuthenticationSetup() {
                        self.updateSupportedBioAuthType(_: self.authenthication.supportBiometricAuthType)
                        self.updateAlertType(_: .enableBiometricsAlert)
                    } else {
                        self.authenthication.updateSigninState(true)
                    }
                }
            }), secondaryButton: .default(Text("Not now"), action: {
                self.authenthication.updateSigninState(true)
            }))
        case .passwordChangeRequired:
            return Alert(title: Text("Change Password"),
                         message: Text("In order to login, your account requires a password change."),
                         dismissButton: .default(Text("Change Now"), action: {self.showSheet.toggle()}))
        case .noAccess:
            return Alert(title: Text("Unauthorized Access"),
                         message: Text("Your account does not have access to this application. \n \nContact Kris Anderson \n+1 479 431 4298"),
                         dismissButton: .default(Text("OK"), action: {}))
        case .offlineDiffirentUser:
            var message = "You are not connected to network, only \n \(UserManager.shared.storedUserName ?? "") \n is able to login. Connect to network to sign in as a diffirent user."
            if UserManager.shared.storedUserName == nil {
                message = "You are not connected to network. You must first login while connected in order to use application in offline mode."
            }
            return Alert(title: Text("Offline"),
                         message: Text(message),
                         dismissButton: .default(Text("OK"), action: {}))
        case .registrationRequired:
            return Alert(title: Text("No Account"),
                         message: Text("Your account does not exist, please register to proceed."),
                         primaryButton: .default(Text("Register Now"), action: {self.showSheet.toggle()}),
                         secondaryButton: .cancel())
        case .inactiveUser:
            return Alert(title: Text("Account Locked"),
                         message: Text("Your account is locked. \n \nContact Kris Anderson \n+1 479 431 4298"),
                         dismissButton: .default(Text("OK"), action: {}))
            
        case .wrongPassword:
            return Alert(title: Text("Invalid Password"),
                         message: Text("Your password is incorrect."),
                         dismissButton: .default(Text("OK"), action: {}))
        default:
            return Alert(title: Text("NOT SETUP ALERT"))
        }
    }
}
