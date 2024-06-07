//
//  AlpineLoginView_V2.swift
//  
//
//  Created by Jenya Lebid on 12/6/23.
//

import SwiftUI

import AlpineUI
import AlpineCore

struct AlpineLoginView_V2: View {
    
    @EnvironmentObject var manager: ConnectManager

    @State private var email = ""
    @State private var password = ""
    @State private var isAlertPresented = false
    @State private var attemptingLogin = false
    @State private var isRegistrationPresented = false
    @State private var isPasswordResetPresented = false
    @State private var isSettingsPresented = false
    @State private var currentAlert = ConnectAlert.empty
    
    var info: LoginConnectionInfo
    var network: NetworkTracker {
        NetworkTracker.shared
    }
    var fieldsEmpty: Bool {
        email.isEmpty || password.isEmpty
    }
    
    public var body: some View {
        VStack {
            logo
            login
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Image("Login-BG").resizable().blur(radius: 50, opaque: true).ignoresSafeArea())
        .overlay(alignment: .bottomTrailing) {
            HStack {
                Text("Version: \(Tracker.appVersion())")
                    .fontWeight(.medium)
                Text("Build: \(Tracker.appBuild())")
                    .fontWeight(.medium)
            }
            .font(.caption)
            .foregroundColor(Color.gray)
            .padding(6)
            .ignoresSafeArea(.keyboard, edges: .all)
            .updateChecker(DBPassword: info.trackingInfo.password, onDismiss: promptBioLogin)
        }
        .overlay(alignment: .bottomLeading) {
            Button {
                self.isSettingsPresented.toggle()
            } label: {
                Image(systemName: "gear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.gray)
            }
            .frame(width: 34, height: 34)
            .padding(.bottom, 6)
            .padding(.horizontal)
            .ignoresSafeArea(.keyboard, edges: .all)
        }
        .connectAlert(currentAlert, isPresented: $isAlertPresented)
        .onAppear {
            fieldsFillCheck()
            NetworkMonitor.shared.start()
        }
        .onDisappear {
            clear()
        }
        .sheet(isPresented: $isRegistrationPresented) {
            RegistationView()
        }
        .sheet(isPresented: $isPasswordResetPresented) {
            PasswordResetView()
        }
        .sheet(isPresented: $isSettingsPresented, content: {
            LaunchSettings()
        })
    }
    
    var logo: some View {
        VStack {
            Image(info.loginPageInfo.logoImageName).resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: 200, minHeight: 0, maxHeight: 200, alignment: .center)
            Text(info.loginPageInfo.companyName)
                .font(.headline)
                .fontWeight(.thin)
                .foregroundColor(Color.white)
            Text(info.loginPageInfo.appName)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.white)
        }
    }
    
    var login: some View {
        VStack {
            TextField("", text: $email)
                .loginField(placeholder: "Email", value: $email)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.bottom, 4)
            passwordField
                .loginField(placeholder: "Password", value: $password)
            Button {
                loginPress()
            } label: {
                Group {
                    if attemptingLogin {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    else {
                        Text("Sign In")
                    }
                }
                .frame(width: 250, height: 60, alignment: .center)
            }
            .foregroundColor(attemptingLogin ? Color.accentColor : Color.white).font(.title)
            .background(Color.accentColor).cornerRadius(15)
            .padding(6)
            HStack {
                Button("Register") {
                    isRegistrationPresented.toggle()
                }
                Divider()
                    .frame(height: 20, alignment: .center)
                Button("Forgot Password?") {
                    isPasswordResetPresented.toggle()
                }
            }
            .padding(.bottom, 8)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .center)
            .disabled(!network.isConnected)
        }
        .padding([.leading, .top, .trailing])
        .background(Color.black.opacity(0.75)).cornerRadius(20)
        .frame(maxWidth: 400, alignment: .center)
        .disabled(attemptingLogin)
    }
    
    var passwordField: some View {
        SecureField("", text: $password)
    }
}

extension AlpineLoginView_V2 {
    
    private func clear() {
        email = ""
        password = ""
    }
    
    private func loginPress(offline: Bool = false) {
        attemptingLogin = true
        
        guard !fieldsEmpty else {
            triggerAlert(with: .empty)
            return
        }
        manager.fillData(email: email, password: password, and: info)
        
        Task {
            do {
                let response = try await manager.attemptLogin(offline: offline)
                DispatchQueue.main.async {
                    self.processLoginResponse(response)
                    attemptingLogin = false
                }
            }
            catch {
                responseFailAlert(for: error)
            }
        }
    }
    
    private func responseFailAlert(for error: Error) {
        var errorDescription = "\(error)"
        if let connectError = error as? ConnectError {
            errorDescription = connectError.message
        }
        currentAlert = ConnectAlert(title: "Something Went Wrong", message: errorDescription)
        
        attemptingLogin = false
        isAlertPresented.toggle()
    }
    
    private func doSignIn() {
        withAnimation {
            manager.isSignedIn = true
        }
    }
    
    fileprivate func triggerAlert(with type: LoginAlertType) {
        attemptingLogin = false
        
        switch type {
        case .empty:
            currentAlert = ConnectAlert(title: "Empty Fields", message: "Both email and password must be filled to continue.")
        }
        
        isAlertPresented.toggle()
    }
}

private extension AlpineLoginView_V2 {
    
    private func promptBioLogin() {
        guard manager.authManager.biometricsAuthorized else { return }
        manager.authManager.runBioAuth { success in
            if success {
                fillPassword()
                loginPress()
            }
        }
        
    }
    
    private func fillPassword() {
        guard let email = manager.core.defaults.lastUser,
              let password = AuthManager.retrieveFromKeychain(account: email)
        else { return }
        
        self.password = password
    }
    
    
    private func fieldsFillCheck() {
        if let email = manager.core.defaults.lastUser {
            self.email = email
        }
        
        #if DEBUG
        fillPassword()
        #endif
    }
}

private extension AlpineLoginView_V2 {
    
    private func processLoginResponse(_ response: ConnectionResponse) {
        switch response.result {
        case .success:
            doSignIn()
        case .fail:
            makeFailAlert(from: response)
        case .moreDetail:
            processDetailResponse(response.detail)
        }
    }
    
    private func makeFailAlert(from response: ConnectionResponse) {
        if let problem = response.problem {
            currentAlert = problem.alert
        }
        else {
            currentAlert = ConnectAlert(title: "Sign In Error", message: "No details were provided. \n\nContact support if the issue persists.")
        }
        
        isAlertPresented.toggle()
    }
    
    
    private func processDetailResponse(_ detail: ConnectionDetail?) {
        guard let detail else {
            currentAlert = ConnectAlert(title: "Sign In Error", message: "Detail response returned no detail. \n\nContact support if the issue persists.")
            isAlertPresented.toggle()
            return
        }
        
        switch detail {
        case .timeout:
            timeoutAlert()
        case .overrideKeychain:
            overrideKeychainAlert()
        case .keychainSaveFail:
            keychainSaveFailAlert()
        case .biometrics:
            biometricsAlert()
        }
        
        isAlertPresented.toggle()
    }
    
    private func timeoutAlert() {
        let offlineButton = ConnectAlertButton(label: "Sign In Offline") {
            loginPress(offline: true)
        }
        let dismissButton = ConnectAlertButton(label: "Cancel", role: .cancel, action: {})
        currentAlert = ConnectAlert(title: "Sign In Timeout", message: "Could not reach network in reasonable time.", buttons: [offlineButton], dismissButton: dismissButton)
    }
    
    private func overrideKeychainAlert() {
        let proceedButton = ConnectAlertButton(label: "Override") {
            processLoginResponse(manager.overrideCredentials())
        }
        let proceedNoOverride = ConnectAlertButton(label: "Proceed Without Override", role: .cancel, action: doSignIn)
        
        currentAlert = ConnectAlert(title: "New Sign In", message: "Your sign in will override previous stored credentials. \n\nGoing forward, any future attempts to sign in while offline will only work for this account unless a new sign in is performed while online.", buttons: [proceedButton], dismissButton: proceedNoOverride)
    }
    
    private func keychainSaveFailAlert() {
        let continueButton = ConnectAlertButton(label: "Proceed Anyway", role: .destructive, action: doSignIn)
        let cancel = ConnectAlertButton(label: "Cancel", role: .cancel, action: {})
        currentAlert = ConnectAlert(title: "Could Not Save Credentials", message: "There was an issue attempting to save sign in information. \n\nOffline Sign In will be availible until saved. \n\nIf the Issue persists, contact support.", buttons: [continueButton], dismissButton: cancel)
    }
    
    private func biometricsAlert() {
        let setUp = ConnectAlertButton(label: "Enable", action: {
            manager.authManager.authorizeBiometrics()
            doSignIn()
        })
        let remindLater = ConnectAlertButton(label: "Remind Me In 3 Days", action: {
            manager.authManager.setRemindLaterForBiometrics()
            doSignIn()
        })

        let continueButton = ConnectAlertButton(label: "Not Now", action: doSignIn)
        
        let alert = ConnectAlert(title: "Enable \(manager.authManager.bioType)", message: "To skip entering password each time, allow for \(manager.authManager.bioType) sign in?", buttons: [setUp, remindLater], dismissButton: continueButton)
        
        currentAlert = alert
    }
}

fileprivate enum LoginAlertType {
    case empty
}
