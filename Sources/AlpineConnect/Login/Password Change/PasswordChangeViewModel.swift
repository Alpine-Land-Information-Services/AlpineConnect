//
//  PasswordChangeViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/27/22.
//

import SwiftUI

class PasswordChangeViewModel: ObservableObject {
    
    var required: Bool
    var status: PasswordChange.Status = .unknownError
    var message = ""
    
    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var repeatedNewPassword: String = ""
    
    @Published var showAlert = false
    @Published var showSpinner = false
    @Published var dismiss = false
    @Published var showPassword = false
    
    init(required: Bool) {
        self.required = required
    }
    
    func allFieldsFilled() -> Bool {
        return oldPassword == "" || newPassword == "" || repeatedNewPassword == ""
    }
    
    func backToLogin() {
        UserManager.shared.inputPassword = ""
        dismiss.toggle()
    }
    
    func sendAlert(alert: PasswordChange.Status) {
        status = alert
        DispatchQueue.main.async {
            self.showAlert.toggle()
        }
    }
    
    func asyncSpinnerChange() {
        DispatchQueue.main.async {
            self.showSpinner.toggle()
        }
    }
    
    func isValidPassword(password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    func changePassword() {
        guard newPassword == repeatedNewPassword else {
            sendAlert(alert: .notMatchedPasswords)
            return
        }
        guard oldPassword == UserManager.shared.password else {
            sendAlert(alert: .invalidCredentials)
            return
        }
        guard newPassword != UserManager.shared.password else {
            sendAlert(alert: .oldPasswordMatch)
            return
        }
        guard isValidPassword(password: newPassword) else {
            sendAlert(alert: .weakPassword)
            return
        }
        guard NetworkMonitor.shared.connected else {
            sendAlert(alert: .notConnected)
            return
        }
        
        showSpinner.toggle()
        
        let info = PasswordChange.PasswordInfo(email: UserManager.shared.userName, currentPassword: UserManager.shared.password, newPassword: newPassword)
        
        Task {
            (status, message) = await PasswordChange.changePassword(info: info)
            
            if status == .passwordChanged {
                UserManager.shared.password = newPassword
                KeychainAuthentication.shared.updateCredentialsOnKeyChain { _ in }
            }
            
            DispatchQueue.main.async {
                self.showSpinner.toggle()
                self.sendAlert(alert: self.status)
            }
        }
        
//        PasswordChange.changePassword(with: newPassword, completionHandler: { changed, errorResponse in
//            if changed {
//                self.sendAlert(alert: .passwordChanged)
//                self.asyncSpinnerChange()
//                self.userManager.password = self.newPassword
//                KeychainAuthentication.shared.updateCredentialsOnKeyChain { _ in }
//            }
//            if let errorResponse = errorResponse {
//                self.unknownErrorMessage = String(describing: errorResponse)
//                self.sendAlert(alert: .unknownError)
//                self.asyncSpinnerChange()
//            }
//        })
    }
    
    func alert() -> (String, String, String, () -> Void) {
        switch status {
        case .notMatchedPasswords:
            return ("Mismatched Fields", "Try Again", "New password fields do not match.", {})
        case .passwordChanged:
            return ("Password Changed", "Back to Login", "Your password has been changed. Use new password at Login.", backToLogin)
        case .invalidCredentials:
            return ("Incorrect Password", "Try Again", "Your old password is incorrect.", {})
        case .unknownError:
            return ("Unknown Error", "OK", "Report this error to the development team: \(message)", {})
        case .oldPasswordMatch:
            return ("Same Password", "Try Again", "Your old password cannot be the same as the new password.", {})
        case .weakPassword:
            return ("Weak Password", "Try Again", "Your new password does not match minumim requirements: At least 6 characters with at at least one letter, special character, and a number.", {})
        case .notConnected:
            return ("Offline", "You are not connected to network, password change is only possible while online.", "OK", {})
        }
    }
}
