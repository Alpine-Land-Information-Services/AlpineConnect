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
    @Published var showPassword = false
    
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
//        guard Check.isValidEmail(userManager.userName) else {
//            loginAlert.updateAlertType(.invalidEmail)
//            return
//        }
        
        spinner.toggle()
        
        userManager.password = userManager.inputPassword
        NetworkManager.update()
        login()
    }
    
    func login() {
        authenthication.authenticateUser(info: makeLoginUpdateInfo()) { response in
            self.handleAuthenticationResponse(_: response)
        }
    }
    
    func makeLoginUpdateInfo() -> Login.UserLoginUpdate {
        return Login.UserLoginUpdate(email: userManager.userName, appName: info.appDBName, info: userManager.userName)
    }
    
    func handleAuthenticationResponse(_ response: LoginResponse) {
        

        
        switch response {
        case .successfulLogin:
            info.appUserFunction { userFunctionResponse in
                switch userFunctionResponse {
                case .successfulLogin:
                    if self.authenthication.askForBioMetricAuthenticationSetup() {
                        self.loginAlert.updateModelState(_: self.authenthication)
                    }
                    else if self.authenthication.areCredentialsSaved() {
                        if self.authenthication.credentialsChanged() {
                            self.loginAlert.updateAlertType(_: .updateKeychainAlert)
                        }
                        else {
                            self.authenthication.updateSigninState(true)
                        }
                    }
                    else {
                        self.authenthication.saveCredentialsToKeyChain()
                        self.authenthication.updateSigninState(true)
                    }
                default:
                    self.loginAlert.updateAlertType(userFunctionResponse)
                }
            }
        default:
            loginAlert.updateAlertType(response)
        }
    }
}
