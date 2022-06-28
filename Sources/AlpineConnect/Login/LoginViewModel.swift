//
//  LoginViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    
    @Published var spinner = false
    @Published var alert = false
    @Published var sheet = false
    
    @Published var userManager = UserAuthenticationManager.shared
    
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
        authenthication.handleBiometricAuthorization()
    }
    
    func updateLoginInfo() {
        let newInfo = LoginConnectionInfo(host: info.host, database: info.database, application: info.application, user: userManager.userName, password: userManager.password)
        LoginConnectionInfo.shared = newInfo
        NetworkManager.update()
    }
    
    func loginButtonPressed() {
        spinner.toggle()
        if !userManager.password.isEmpty && !userManager.userName.isEmpty {
            updateLoginInfo()
            login()
        } else {
            loginAlert.updateAlertType(_: .emptyFields)
        }
    }
    
    func login() {
        authenthication.authenticateUser { response in
            self.handleAuthenticationResponse(_: response)
        }
    }
    
    func handleAuthenticationResponse(_ response: LoginResponseMessage) {
        switch response {
        case .successfulLogin:
            if authenthication.areCredentialsSaved() {
                if authenthication.credentialsChanged() {
                    loginAlert.updateAlertType(_: .updateKeychainAlert)
                }
                else {
                    authenthication.updateSigninState(_: true, _: .online)
                }
            }
            else if authenthication.askForBioMetricAuthenticationSetup() {
                loginAlert.updateModelState(_: authenthication)
            }
            else {
                loginAlert.updateAlertType(_: .keychainAlert)
            }
        case .passwordChangeRequired:
            loginAlert.updateAlertType(.updatePassword)

        default:
            loginAlert.loginResponse = response
            loginAlert.updateAlertType(_: .authenticationAlert)
        }
    }
}
