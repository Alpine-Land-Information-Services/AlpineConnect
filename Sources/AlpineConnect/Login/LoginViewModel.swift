//
//  LoginViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    
    @Published var spinner = false
    @Published var register = false
    @Published var showResetPassword = false
    
    @Published var userManager = UserManager.shared
    
    var loginAlert = LoginAlert.shared
    var authenthication = KeychainAuthentication.shared
    
    var info: LoginConnectionInfo
    
    init(info: LoginConnectionInfo) {
        self.info = info
        setLoginConnectionInfo()
    }
    
    func setLoginConnectionInfo() {
        NetworkMonitor.shared.start()
        LoginConnectionInfo.shared = info
        authenthication.fetchCredentialsFromKeyChain()
        authenthication.handleBiometricAuthorization { result in
            if result {
                self.login()
            }
        }
    }

    func loginButtonPressed() {
        guard !userManager.inputPassword.isEmpty && !userManager.userName.isEmpty else {
            loginAlert.updateAlertType(_: .emptyFields)
            return
        }
        guard Check.isValidEmail(userManager.userName) else {
            loginAlert.updateAlertType(.invalidEmail)
            return
        }
        
        spinner.toggle()
        
        userManager.password = userManager.inputPassword
        NetworkManager.update()
        login()
    }
    
    func login() {
        authenthication.authenticateUser { response in
            self.handleAuthenticationResponse(_: response)
        }
    }
    
    func handleAuthenticationResponse(_ response: LoginResponseMessage) {
        switch response {
        case .successfulLogin:
            if authenthication.askForBioMetricAuthenticationSetup() {
                loginAlert.updateModelState(_: authenthication)
            }
            else if authenthication.areCredentialsSaved() {
                if authenthication.credentialsChanged() {
                    loginAlert.updateAlertType(_: .updateKeychainAlert)
                }
                else {
                    authenthication.updateSigninState(true)
                }
            }
            else {
                authenthication.saveCredentialsToKeyChain()
                authenthication.updateSigninState(true)
            }
        default:
            loginAlert.updateAlertType(response)
        }
    }
}
