//
//  LoginAlertViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import SwiftUI
import LocalAuthentication

class LoginAlert: ObservableObject {
    
    static let shared = LoginAlert()
    
    @Published var showAlert = false
    @Published var showSheet = false
    
    @Published var showNewAlert = false
    
    var activeAlert: LoginResponse = .noAccess
    var loginResponse: LoginResponse?
    
    var authenthication = KeychainAuthentication.shared
    var supportedBioAuthType: String?
    var biometricErrorCode: Int?
    
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
    
    func updateNewAlertType(_ type: LoginResponse) {
        activeAlert = type
        
        DispatchQueue.main.async {
            self.showNewAlert.toggle()
        }
    }
    
    func updateModelState(_ authenthication: KeychainAuthentication) {
        supportedBioAuthType = authenthication.supportBiometricAuthType == .faceID ? "Face ID" : "Touch ID"
        guard let bioError = authenthication.biometricError else {
            updateNewAlertType(.enableBiometricsAlert)
            return
        }
        
        if authenthication.checkIfPromptForBioSetUp() {
            determineBioErrorAlert(error: bioError)
        }
        else {
            authenthication.updateSigninState(true)
        }
    }
    
    func determineBioErrorAlert(error: NSError) {
        switch LAError.Code(rawValue: error.code)! {
        case .passcodeNotSet:
            updateNewAlertType(.passcodeNotSet)
        case .touchIDNotEnrolled:
            updateNewAlertType(.bioNotSet)
        default:
            biometricErrorCode = error.code
            updateNewAlertType(.unknownBioError)
        }
    }
    
    func continueWithLogin() {
        authenthication.saveCredentialsToKeyChain()
        authenthication.updateBioNotNowCount()
        authenthication.updateSigninState(true)
    }
    
    func remindLaterForBioSetup() {
        authenthication.saveCredentialsToKeyChain()
        authenthication.saveBiometricAuthRequestTimeInUserDefault()
        authenthication.updateBioNotNowCount(reset: true)
        authenthication.updateSigninState(true)
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
        case .updateKeychainAlert:
            return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: .default(Text("Update"), action: {
                self.authenthication.updateCredentialsOnKeyChain { _ in
                    self.authenthication.updateSigninState(true)
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
            return Alert(title: Text("Something Went Wrong"), message: Text("Please try again. \n Error: \n \(Login.loginResponse)"))

        }
    }
    
    func newAlert() -> CustomAlert {
        switch activeAlert {
        case .enableBiometricsAlert:
            let alertButtons = ThreeButtonAlert(label1: "Setup Now", action1: {
                self.authenthication.setupBioMetricAuthentication { result in
                    if result {
                        self.authenthication.biometricLoginEnabled = true
                    }
                    self.continueWithLogin()
                }
            }, label2: "Not Now", action2: continueWithLogin, dontRemind: true, label3: "Remind Me in 3 Days", action3: remindLaterForBioSetup)
            let message = "This will expedite future sign in by not having to enter your password manually."
            
            return CustomAlert(title: "Set Up \(supportedBioAuthType ?? "")?", message: message, buttons: AnyView(alertButtons))
        case .passcodeNotSet:
            let alertButtons = ThreeButtonAlert(label1: "Set Up in Settings", action1: {UIApplication.shared.open(URL(string: "App-prefs:")!)}, label2: "Not Now", action2: continueWithLogin, dontRemind: true, label3: "Remind Me in 3 Days", action3: remindLaterForBioSetup)
            let message = "Your device does not have a passcode. Set it up in order to skip entering your password manually, and use \(supportedBioAuthType ?? "") for future sign in."
            
            return CustomAlert(title: "Passcode Not Setup", message: message, buttons: AnyView(alertButtons))
        case .bioNotSet:
            let alertButtons = ThreeButtonAlert(label1: "Enable in Settings", action1: {UIApplication.shared.open(URL(string: "App-prefs:")!)}, label2: "Not Now", action2: continueWithLogin, dontRemind: true, label3: "Remind Me in 3 Days", action3: remindLaterForBioSetup)
            let message = "Enable \(supportedBioAuthType ?? "") on your device in order to skip entering your password for future sign in."
            
            return CustomAlert(title: "\(supportedBioAuthType ?? "") Not Setup", message: message, buttons: AnyView(alertButtons))
        default:
            let alertButtons = OneButtonAlert(label: "OK", action: {})
            let message = "Report error code to support. Error Code: \(biometricErrorCode ?? -1000)"
            
            return CustomAlert(title: "Unknown Biometric Alert", message: message, buttons: AnyView(alertButtons))
        }
    }
    
    struct CustomAlert {
        
        var title: String
        var message: String
        
        var buttons: AnyView
    }
    
    struct OneButtonAlert: View {
        
        var label: String
        var action: () -> ()
        
        var body: some View {
            Button {
                action()
            } label: {
                Text(label)
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    struct TwoButtonAlert: View {
        
        var label1: String
        var action1: () -> ()
        
        var label2: String
        var action2: () -> ()
        
        var body: some View {
            HStack {
                Button {
                    action1()
                } label: {
                    Text(label1)
                        .foregroundColor(.accentColor)
                }
                Button(role: .cancel) {
                    action2()
                } label: {
                    Text(label2)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    struct ThreeButtonAlert: View {
        
        
        var label1: String
        var action1: () -> ()
        
        var label2: String
        var action2: () -> ()
        
        var dontRemind: Bool
        
        var label3: String
        var action3: () -> ()
        
        var body: some View {
            VStack {
                Button {
                    action1()
                } label: {
                    Text(label1)
                }
                Button(role: .cancel) {
                    action2()
                } label: {
                    Text(label2)
                }
                if dontRemind {
                    Button(role: .destructive) {
                        action3()
                    } label: {
                        Text(label3)
                    }
                }
            }
        }
    }
}
