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
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    var showBioIcon: Bool = false
    
    var loginAlert = LoginAlert.shared
    var authenthication = KeychainAuthentication.shared
    
    var info: LoginConnectionInfo
    
    init(info: LoginConnectionInfo) {
        self.info = info
        showBioIcon = KeychainAuthentication.shared.biometricLoginEnabled
        setLoginConnectionInfo()
        
        NotificationCenter.default.addObserver(self, selector: #selector(offlineLogin), name: Notification.Name("CONNECT_OFFLINE"), object: nil)
    }
    
    func bioAuthentication() {
        authenthication.handleBiometricAuthorization { result in
            if result {
                self.doLogin()
            }
        }
    }
    
    func bioClickAuthentication() {
        guard authenthication.biometricLoginEnabled else {
            return
        }
        authenthication.handleBiometricAuthorization { result in
            if result {
                self.doLogin()
            }
        }
    }
    
    func setLoginConnectionInfo() {
        NetworkMonitor.shared.start()
        Location.shared.start()
//        LoginConnectionInfo.shared = info
        authenthication.fetchCredentialsFromKeyChain()
    }

    func loginButtonPressed() {
        guard !userManager.inputPassword.isEmpty && !userManager.userName.isEmpty else {
            loginAlert.updateAlertType(.emptyFields)
            return
        }
        doLogin(manual: true)
    }
    
    func doLogin(manual: Bool = false) {
        DispatchQueue.main.async { [self] in
            if manual {
                userManager.userName = userManager.userName.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_")
                userManager.password = userManager.inputPassword
            }
            NetworkManager.update()
            login()
        }
    }
    
    @objc
    func offlineLogin() {
        DispatchQueue.main.async {
            self.spinner.toggle()
        }
        self.handleOfflineAuthenticationResponse()
    }
    
    func login() {
        DispatchQueue.main.async { [self] in
            spinner.toggle()
            if NetworkMonitor.shared.connected {
                Login.loginUser(info: makeLoginUpdateInfo(), completionHandler: { response in
                    self.handleOnlineAuthenticationResponse(response)
                })
            } else {
                self.handleOfflineAuthenticationResponse()
            }
        }
    }
    
    func makeLoginUpdateInfo() -> Login.UserLoginUpdate {
//        let login = Login.UserLoginUpdate(email: userManager.userName, password: userManager.password, appName: info.appDBName, appVersion: Tracker.appVersion(), machineName: Tracker.deviceName(), info: userManager.userName)
//        userManager.loginUpdate = login
//        return login
        
        fatalError()
    }
    
    func handleOfflineAuthenticationResponse() {
        let response = authenthication.offlineCheck(email: userManager.userName)
        switch response {
        case .successfulLogin:
            performLogin()
        default:
            loginAlert.updateAlertType(response)
        }
    }
    
    func handleOnlineAuthenticationResponse(_ response: LoginResponse) {
        switch response {
        case .successfulLogin:
            return
//            info.appUserFunction { userFunctionResponse in
//                switch userFunctionResponse {
//                case .successfulLogin:
//                    self.performLogin()
//                default:
//                    self.loginAlert.updateAlertType(userFunctionResponse)
//                }
//            }
        default:
            loginAlert.updateAlertType(response)
        }
    }
    
    private func performLogin() {
        if self.authenthication.askForBioMetricAuthenticationSetup() || self.inDEBUG {
            if self.inDEBUG {
                self.savePasswordForDEBUG()
            }
            else {
                self.loginAlert.updateModelState(_: self.authenthication)
            }
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
    }
}

extension LoginViewModel {
    
    var inDEBUG: Bool {
        #if DEBUG
            return !UserDefaults().bool(forKey: "debugPasswordSave")
        #else
            return false
        #endif
    }
    
    func savePasswordForDEBUG() {
        loginAlert.updateAlertType(.debug)
    }
}
