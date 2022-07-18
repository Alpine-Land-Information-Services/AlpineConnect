//
//  RegisterViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/8/22.
//

import SwiftUI

class RegisterViewModel: ObservableObject {
    
    var securityQuestions1Options = [["What is the name of your first pet?"], ["What is your favorite color?"], ["What is the name of your best friend?"]]
    var securityQuestions2Options = [["What is the model of your first car?"], ["What was your dream job?"], ["What is the name the city you were born in?"]]
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = UserManager.shared.userName
    @Published var confirmEmail = ""
    
    @Published var showAlert = false
    @Published var showSpinner = false
    @Published var open: Bool
    
    init(open: Bool) {
        self.open = open
    }
    
    var registerStatus: Register.RegisterResponse = .unknownError
    var registerMesssage = ""
    
    func submit() {
        guard Check.isValidEmail(email) else {
            registerStatus = .invalidEmail
            showAlert.toggle()
            return
        }
        guard !checkMissingRequirements() && email == confirmEmail else {
            registerStatus = .missingFields
            
            if email != confirmEmail {
                registerStatus = .emailsDiffer
            }
            
            showAlert.toggle()
            return
        }
        guard NetworkMonitor.shared.connected else {
            registerStatus = .notConnected
            showAlert.toggle()
            return
        }
        
        showSpinner.toggle()
        
        Task {
            (registerStatus, registerMesssage) = await Register.registerUser(info: makeInfo())
            DispatchQueue.main.async {
                self.showSpinner.toggle()
                self.showAlert.toggle()
            }
        }
    }
    
    func checkMissingRequirements() -> Bool {
        if firstName == "" || lastName == "" {
            return true
        }
        if email == "" || confirmEmail == "" {
            return true
        }
        return false
    }
    
    func alert() -> (String, String, String, () -> ()) {
        switch registerStatus {
        case .invalidEmail:
            return ("Invalid Email", "Enter a valid email address, with @ symbol and domain.", "Try Again", {})
        case .missingFields:
            return ("Missing Fields", "Fill out all of the fields outlined in red.", "Try Again", {})
        case .registerSuccess:
            return ("Successful Registration", "You are now registerd, temporary password will be emailed to you shortly.", "OK", {self.open.toggle()})
        case .requestSent:
            return ("Request Sent", "Your registration request is sent to administrator. Once approved, you will be emailed a temporary password.", "OK", {self.open.toggle()})
        case .userExists:
            return ("User Exists", "There is already an account associated with provided email.", "OK", {})
        case .emailsDiffer:
            return ("Email Mismatch", "Make sure both email fields are the same.", "Try Again", {})
        case .notConnected:
            return ("Offline", "You are not connected to network, registration is only possible while online.", "OK", {})
        default:
            return ("Unknown Error", "Registration error code: \(registerMesssage), contact support.", "OK", {})
        }
    }
    
    func makeInfo() -> Register.RegistrationInfo {
        return Register.RegistrationInfo(email: email, firstName: firstName, lastName: lastName)
    }
}
