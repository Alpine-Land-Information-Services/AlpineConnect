//
//  LoginAlertViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import SwiftUI

final class CustomAlertViewModel: ObservableObject {
    
    @Published var activeAlert: AlertType = .authenticationAlert
    @Published var loginResponse: LoginResponseMessage?
    @Published var showAlertMessage: Bool = false
    var supportedBioAuthType: String? = nil

    var alertTitle: String {
        if activeAlert == .biometricAuthAlert {
            return "Set up biometric authentication"
        } else if activeAlert == .updateKeychainAlert {
            return "Update stored login credentials in memory"
        } else {
            return "Save login credentials? "
        }
    }

    var alertMessage: String {
        if activeAlert == .biometricAuthAlert {
            return "Your device supports \(supportedBioAuthType ?? "") sign in. You can enable this to expedite future sign in processes"
        } else if  activeAlert == .updateKeychainAlert {
            return "Update your stored credentials with the latest login credentials"
        } else {
            return "This will expedite future login processes"
        }
    }
    
    func emptyFieldAlert() {
        self.showAlertMessage = true
        activeAlert = .emptyFields
    }

    func updateShowAlertStatus(_ showingAlert: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)  {
            self.showAlertMessage = showingAlert
        }
    }

    func updateAlertType(_ alertType: AlertType) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.activeAlert = alertType
        }
    }

    func updateSupportedBioAuthType(_ type: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)  {
            self.supportedBioAuthType = type
        }
    }

    func updateModelState(_ loginViewModel: AuthenticationViewModel){
        updateSupportedBioAuthType(_: loginViewModel.supportBiometricAuthType)
        supportedBioAuthType = loginViewModel.supportBiometricAuthType
        updateShowAlertStatus(_: true)
        updateAlertType(_: .biometricAuthAlert)
    }
}

enum AlertType {
    case authenticationAlert
    case emptyFields
    case keychainAlert
    case biometricAuthAlert
    case updateKeychainAlert
}
