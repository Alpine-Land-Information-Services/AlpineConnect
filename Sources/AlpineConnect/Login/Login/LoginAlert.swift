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
    
    var activeAlert: LoginResponse = .noAccess
    var loginResponse: LoginResponse?
    
    var authenthication = KeychainAuthentication.shared
    var supportedBioAuthType: String? = nil
    
    var alertTitle: String {
        if activeAlert == .enableBiometricsAlert {
            return "Set Up \(supportedBioAuthType ?? "")?"
        } else if activeAlert == .updateKeychainAlert {
            return "Update Stored Login Credentials in Memory?"
        } else {
            return "Save Login Credentials?"
        }
    }
    
    var alertMessage: String {
        if activeAlert == .enableBiometricsAlert {
            return "This will expedite future sign in by not having to enter your password manually."
        } else if  activeAlert == .updateKeychainAlert {
            return "Update your stored credentials with the latest login credentials."
        } else {
            return "This will expedite future sign in."
        }
    }
    
    func updateAlertType(_ alertType: LoginResponse) {
        DispatchQueue.main.async {
            self.showAlert.toggle()
        }
        self.activeAlert = alertType
    }
    
    func updateModelState(_ authenthication: KeychainAuthentication) {
        supportedBioAuthType = authenthication.supportBiometricAuthType
        authenthication.saveBiometricAuthRequestTimeInUserDefault()
        updateAlertType(_: .enableBiometricsAlert)
    }
    
    func alert() -> Alert {
        switch activeAlert {
        case .authenticationAlert:
            if loginResponse != .successfulLogin {
                return Alert(title: Text(loginResponse?.rawValue.0 ?? ""), message: Text(loginResponse?.rawValue.1 ?? ""), dismissButton: .default(Text("OK"), action: {
                    return;
                }))
            } else {
                return Alert(title: Text(""))
            }
        case .emptyFields:
            return Alert(title: Text("Empty Fields"), message: Text("All login fields must be filled."), dismissButton: .default(Text("OK"), action: {
                return;
            }))
        case .enableBiometricsAlert:
            return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Set Up"), action: {
                self.authenthication.setupBioMetricAuthentication { result in
                    self.authenthication.saveCredentialsToKeyChain()
                    self.authenthication.updateSigninState(true)
                }
            }), secondaryButton: .default(Text("Not now"), action: {
                self.authenthication.saveCredentialsToKeyChain()
                self.authenthication.updateSigninState(true)
            }))
        case .updateKeychainAlert:
            return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Update"), action: {
                self.authenthication.updateCredentialsOnKeyChain { _ in
                    if self.authenthication.askForBioMetricAuthenticationSetup() {
                        self.supportedBioAuthType = self.authenthication.supportBiometricAuthType
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
            let message = "You are not connected to network, only \n \(UserManager.shared.storedUserName ?? "") \n is able to login. Connect to network to sign in as a diffirent user."
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
        case .networkError:
            return Alert(title: Text("Offline"),
                         message: Text("You are not connected to network. You must first login while connected in order to use application in offline mode."),
                         dismissButton: .default(Text("OK"), action: {}))
        case .invalidEmail:
            return Alert(title: Text("Invalid Email"),
                         message: Text("Enter a valid email address, with @ symbol and domain."),
                         dismissButton: .default(Text("OK"), action: {}))
        default:
            return Alert(title: Text("UNKNOWN ALERT: \(activeAlert.rawValue.0 + "" + activeAlert.rawValue.1)"))
        }
    }
}
