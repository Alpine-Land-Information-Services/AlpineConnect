//
//  LoginViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    
    @Published var userManager = UserAuthenticationManager.shared
    var loginAlert = LoginAlert()
    
    @Published var spinner = false
    @Published var alert = false
    @Published var sheet = false
    
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
        if !userManager.password.isEmpty && !userManager.userName.isEmpty {
            spinner.toggle()
            updateLoginInfo()
            login()
        } else {
            loginAlert.emptyFieldAlert()
            alert.toggle()
        }
    }
    
    func login() {
        authenthication.authenticateUser { response in
            self.handleAuthenticationResponse(_: response)
        }
    }
    
    func handleAuthenticationResponse(_ response: LoginResponseMessage) {
        if response == .successfulLogin {
            if authenthication.areCredentialsSaved() {
                if authenthication.credentialsChanged() {
                    loginAlert.updateAlertType(_: .updateKeychainAlert)
                    loginAlert.updateShowAlertStatus(_: true)
                } else {
                    if authenthication.askForBioMetricAuthenticationSetup() {
                        loginAlert.updateModelState(_: authenthication)
                        alert.toggle()
                    } else {
                        authenthication.updateSigninState(_: true, _: .online)
                    }
                }
            } else {
                loginAlert.updateShowAlertStatus(_: true)
                loginAlert.updateAlertType(_: .keychainAlert)
            }
        } else {
            DispatchQueue.main.async {
                self.loginAlert.loginResponse = response
                self.loginAlert.updateShowAlertStatus(_: true)
                self.loginAlert.updateAlertType(_: .authenticationAlert)
                self.spinner.toggle()
                self.alert.toggle()
            }
        }
    }
}
