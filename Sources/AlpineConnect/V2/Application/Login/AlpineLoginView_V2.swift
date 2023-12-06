//
//  AlpineLoginView_V2.swift
//  
//
//  Created by Jenya Lebid on 12/6/23.
//

import SwiftUI
import AlpineUI

struct AlpineLoginView_V2: View {
    
    @EnvironmentObject var manager: AppManager
    @ObservedObject var networkMonitor = NetworkMonitor.shared
    
    @State private var userName = ""
    @State private var password = ""
    
    @State private var isAlertPresented = false
    @State private var attemptingLogin = false
    
    @State private var currentAlert = ConnectAlert.empty
    
    var info: LoginConnectionInfo
    
    public var body: some View {
        VStack {
            logo
            login
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Image("Login-BG").resizable().blur(radius: 50, opaque: true).ignoresSafeArea())
        .overlay {
            HStack {
                Text("Version: \(Tracker.appVersion())")
                    .fontWeight(.medium)
                Text("Build: \(Tracker.appBuild())")
                    .fontWeight(.medium)
            }
            .font(.caption)
            .foregroundColor(Color.gray)
            .padding(6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .ignoresSafeArea(.keyboard, edges: .all)
        }
        .alert(currentAlert.title, isPresented: $isAlertPresented, actions: {
            if let buttons = currentAlert.buttons {
                ForEach(buttons, id: \.label) { button in
                    Button(role: button.role) {
                        button.action()
                    } label: {
                        Text(button.label)
                    }
                }
            }
            if let button = currentAlert.dismissButton {
                Button(role: button.role) {
                    button.action()
                } label: {
                    Text(button.label)
                }
            }
            else {
                Button(role: .cancel) {
                    
                } label: {
                    Text("Okay")
                }
            }
        }, message: {
            if let message = currentAlert.message {
                Text(message)
            }
        })
        .onAppear {
            
        }
        .onDisappear {
            clear()
        }
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
            TextField("", text: $userName)
                .loginField(placeholder: "Email", value: $userName)
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
                    
                }
                Divider()
                    .frame(height: 20, alignment: .center)
                Button("Forgot Password?") {
                    
                }
            }
            .padding(.bottom, 8)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .center)
            .disabled(!networkMonitor.connected)
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
    
    var fieldsEmpty: Bool {
        userName.isEmpty || password.isEmpty
    }
    
    func clear() {
        userName = ""
        password = ""
    }
    
    func loginPress() {
        attemptingLogin = true
        
        guard !fieldsEmpty else {
            triggerAlert(with: .empty)
            return
        }
        
    }
    
    fileprivate func triggerAlert(with type: LoginAlertType) {
        attemptingLogin = false
        
        switch type {
        case .empty:
            currentAlert = ConnectAlert.emptyFields
        }
        
        isAlertPresented.toggle()
    }
}

private extension ConnectAlert {
    
    static var emptyFields: ConnectAlert {
        ConnectAlert(title: "Empty Fields", message: "Both email and password must be filled to continue.")
    }
}

fileprivate enum LoginAlertType {
    case empty
}
