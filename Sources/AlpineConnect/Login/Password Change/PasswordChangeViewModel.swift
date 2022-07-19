//
//  PasswordChangeViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/27/22.
//

import SwiftUI

class PasswordChangeViewModel: ObservableObject {
    
    enum PasswordScore {
        case blank
        case veryWeak
        case weak
        case medium
        case strong
        case veryStrong
    }
    
    var required: Bool
    var status: PasswordChange.Status = .unknownError
    var message = ""
    
    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var repeatedNewPassword: String = ""
    
    @Published var passwordStrenght = "Blank"
    
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
    
    func checkPassStr(_ str: PasswordScore) -> (String, Bool) {
        switch str {
        case .blank:
            return ("Blank", false)
        case .veryWeak:
            return ("Very Weak", false)
        case .weak:
            return ("Weak", false)
        case .medium:
            return ("Medium", true)
        case .strong:
            return ("Strong", true)
        case .veryStrong:
            return ("Very Strong", true)
        }
    }
    
    func checkPasswordScore(password: String) -> PasswordScore {
        var score = 0
        
        if password.count < 1 {
            return .blank
        }
        if password.count < 4 {
            return .veryWeak
        }
        if password.count >= 8 {
           score += 1
        }
        if password.count >= 12 {
            score += 1
        }
        if password.rangeOfCharacter(from: NSCharacterSet.lowercaseLetters) != nil {
            score += 1
        }
        if password.rangeOfCharacter(from: NSCharacterSet.uppercaseLetters) != nil {
            score += 1
        }
        if password.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil {
            score += 1
        }
                                          
        let specialChars = CharacterSet(charactersIn: #"@%!@#$%^&*()?/>.<,:;'\|}]{[_~`+=-" + "\""#)
        if password.rangeOfCharacter(from: specialChars) != nil {
            score += 1
        }
        
        if score > 5 {
            score = 5
        }
        if password.count < 12 && score == 5 {
            score = 4
        }
        
        switch score {
        case 1:
            return .veryWeak
        case 2:
            return .weak
        case 3:
            return .medium
        case 4:
            return .strong
        case 5:
            return .veryStrong
        default:
            return .blank
        }
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
        guard checkPassStr(checkPasswordScore(password: newPassword)).1 else {
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
            return ("Weak Password", "Try Again", "Your new password must be at least medium strength.", {})
        case .notConnected:
            return ("Offline", "You are not connected to network, password change is only possible while online.", "OK", {})
        }
    }
}
