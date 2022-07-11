//
//  RegisterViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/8/22.
//

import SwiftUI
import SwiftSMTP

class RegisterViewModel: ObservableObject {
    
    var securityQuestions1Options = [["What is the name of your first pet?"], ["What is your favorite color?"], ["What is the name of your best friend?"]]
    var securityQuestions2Options = [["What is the model of your first car?"], ["What was your dream job?"], ["What is the name the city you were born in?"]]
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = UserManager.shared.userName
    @Published var confirmEmail = ""
    
    @Published var showAlert = false
    @Published var open: Bool
    
    init(open: Bool) {
        self.open = open
    }
    
    var registerStatus: Register.RegisterResponse = .none
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func submit() {
        guard isValidEmail(email) else {
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
        
        Register.registerUser(info: makeInfo()) { response in
            self.registerStatus = response
            DispatchQueue.main.async {
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
            return ("Success", "Your registration was sucessfull, a one time password will be sent to your email.", "OK", {self.open.toggle()})
        case .userExists:
            return ("User Exists", "There is already an account associated with provided email.", "OK", {})
        case .emailsDiffer:
            return ("Email Mismatch", "Make sure both email fields are the same.", "Try Again", {})
        default:
            return ("Unknown Error", "Unknown Registration error, contact support.", "OK", {})
        }
    }
    
    func makeInfo() -> Register.RegistrationInfo {
        return Register.RegistrationInfo(email: email, firstName: firstName, lastName: lastName)
    }
    
    
    func sendEmail() {
        let sender = Mail.User(name: "Alpine LIS", email: "")
        let reciever = Mail.User(name: firstName + "" + lastName, email: email)
        
        let mail = Mail(from: sender, to: [reciever], subject: "", text: "")
    }
}
