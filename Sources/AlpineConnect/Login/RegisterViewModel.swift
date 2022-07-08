//
//  RegisterViewModel.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/8/22.
//

import SwiftUI
import SwiftSMTP

class RegisterViewModel: ObservableObject {
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    
    @Published var alert = false
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func submit() {
        guard isValidEmail(email) else {
            alert.toggle()
            return
        }
    }
    
    func submitEnabled() -> Bool {
        return firstName.isEmpty || lastName.isEmpty || email.isEmpty
    }
    
    func sendEmail() {
        let sender = Mail.User(name: "Alpine LIS", email: "")
        let reciever = Mail.User(name: firstName + "" + lastName, email: email)
        
        let mail = Mail(from: sender, to: [reciever], subject: "", text: "")
    }
}
