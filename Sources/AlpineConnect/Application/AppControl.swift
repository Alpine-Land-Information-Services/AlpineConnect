//
//  AppControl.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 10/14/22.
//

import SwiftUI
import AlpineUI

open class AppControl: ObservableObject {
    
    static public var shared = AppControl()
        
    @Published public var showRegularAlert = false
    @Published public var showSheetAlert = false
    
    @Published public var showCover = false
    
    @Published public var showSheet = false
    @Published public var showPopup = false
    @Published public var showSecondaryPopup = false
    
    public var currentAlert = AppAlert(title: "", message: "", dismiss: AlertAction(text: ""), actions: [])
    public var currentSheet = AnyView(EmptyView())
    
    public var currentCover = AnyView(EmptyView())
    
    public var currentPopup = AppPopup {AnyView(EmptyView())}
    public var currentSecondaryPopup = AppPopup {AnyView(EmptyView())}
        
    public var dimView: Bool {
        get {
            if showRegularAlert || showPopup {
                return true
            }
            return false
        }
        set {}
    }
    
    public var sheetDimView: Bool {
        get {
            if showSheetAlert || showPopup {
                return true
            }
            return false
        }
        set {}
    }
    
    public var showAlert: Bool {
        get {
            if showSheet {
                return showSheetAlert
            }
            else {
                return showRegularAlert
            }
        }
        set {
            if showSheet {
                showSheetAlert = newValue
            }
            else {
                showRegularAlert = newValue
            }
        }
    }
    
    public init() {}
    
    public func showMainPopup(_ value: Bool? = nil) {
        withAnimation {
            if let value {
                showPopup = value
            }
            else {
                showPopup.toggle()
            }
        }
    }
    
    public func showSecondaryPopup(_ value: Bool?) {
        withAnimation {
            if let value {
                showSecondaryPopup = value
            }
            else {
                showSecondaryPopup.toggle()
            }
        }
    }
}

extension AppControl { //MARK: Popups
    
    static public func showSheet(view: any View) {
        DispatchQueue.main.async {
            withAnimation {
                if AppControl.shared.showSheet {
                    AppControl.shared.showSheet.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                        showSheet(view: view)
                    }
                }
                else {
                    AppControl.shared.currentSheet = AnyView(view)
                    AppControl.shared.showSheet.toggle()
                }
            }
        }
    }
    
    static public func showCover(view: any View) {
        DispatchQueue.main.async {
            withAnimation {
                AppControl.shared.currentCover = AnyView(view)
                AppControl.shared.showCover.toggle()
            }
        }
    }
}


extension AppControl { //MARK: Alerts
    
    public static func noConnectionAlert() {
        let alert = AppAlert(title: "Offline", message: "You are not connected to network, please connect to proceed.")
        AppControl.shared.toggleAlert(alert)
    }
    
    private func showAlertToggle() {
        DispatchQueue.main.async {
            withAnimation {
                self.showAlert.toggle()
            }
        }
    }
    
    public func toggleAlert(_ alert: AppAlert) {
        if showAlert {
            showAlertToggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.currentAlert = alert
                self.showAlertToggle()
            }
        }
        else {
            currentAlert = alert
            showAlertToggle()
        }
    }
    
    private func errorAlert(title: String, error: Error, customDescription: String?) {
        if error.log().contains("socketError(cause:")
            || error.log().contains("connectionClosed")
        {
            let alert = AppAlert(title: "\(title) Error", message: "Server error. Please try again.", dismiss: AlertAction(text: "Okay"), actions: [])
            toggleAlert(alert)
            return
        }
        
        let alert = AppAlert(title: "\(title) Error", message: "\(error.localizedDescription) \n-----\n Check error logs for detailed description.", dismiss: AlertAction(text: "Okay"), actions: [AlertAction(text: "Report", role: .alert, action: {
            AppControl.showSheet(view: {
                NavigationView {
                    ReportIssueView(userName: CurrentUser.fullName, email: CurrentUser.email, title: title, text: error.log() + "\n" + (customDescription ?? "No additional information."))
                }
                .navigationViewStyle(.stack)
            }())
        })])
        toggleAlert(alert)
    }
    
    public static func makeError(onAction: String, error: Error, customDescription: String? = nil, showToUser: Bool = true) {
        AppError.add(onAction: onAction, log: error.log(), customDescription: customDescription)
        if showToUser {
            AppControl.shared.errorAlert(title: onAction, error: error, customDescription: customDescription)
        }
    }
    
    public static func doRestart(title: String, message: String) {
        let alert = AppAlert(title: title, message: message,
                             dismiss: AlertAction(text: "Quit App", role: .regular, action: {
                     exit(0)
                 }))
        AppControl.shared.toggleAlert(alert)
    }
    
    public static func successfulSyncAlert() {
        let alert = AppAlert(title: "Sync Successful", message: "Local data has been sucessfully exported and updated.")
        AppControl.shared.toggleAlert(alert)
    }
    
    public static func makeSimpleAlert(title: String, message: String) {
        let alert = AppAlert(title: title, message: message)
        AppControl.shared.toggleAlert(alert)
    }
    
    public static func makeAlert(alert: AppAlert) {
        AppControl.shared.toggleAlert(alert)
    }
    
    public static func notDoneAlert() {
        AppControl.makeSimpleAlert(title: "Not Implemented", message: "This functionality has not yet been added, check back later.")
    }
}

extension AppControl {
    
    static public func connectionRequiredAction(_ action: @escaping () -> ()) {
        guard NetworkMonitor.shared.connected else {
            noConnectionAlert()
            return
        }
        action()
    }
    
    static public func waitForKeyboardCloseAction(_ action: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            action()
        }
    }
}

extension UIApplication {
    var isKeyboardPresented: Bool {
        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"), self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
            return true
        } else {
            return false
        }
    }
}
