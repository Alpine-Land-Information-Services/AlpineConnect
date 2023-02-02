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
    
    @Published public var showSheet = false
    @Published public var showPopup = false
    @Published public var showSecondaryPopup = false
    
    public var currentAlert = AppAlert(title: "", message: "", dismiss: AlertAction(text: ""), actions: [])
    public var currentSheet = AnyView(EmptyView())
    
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
        AppControl.shared.currentSheet = AnyView(view)
        withAnimation {
            AppControl.shared.showSheet.toggle()
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
    
    private func errorAlert(title: String, error: Error) {
        let alert = AppAlert(title: "\(title) Error", message: "\(error.localizedDescription) \n-----\n Check error logs for detailed description.")
        toggleAlert(alert)
    }
    
    public static func makeError(onAction: String, error: Error, showToUser: Bool = true) {
        AppError.add(onAction: onAction, log: error.log())
        if showToUser {
            AppControl.shared.errorAlert(title: onAction, error: error)
        }
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
}

extension AppControl {
    
    static public func connectionRequiredAction(_ action: @escaping () -> ()) {
        guard NetworkMonitor.shared.connected else {
            noConnectionAlert()
            return
        }
        action()
    }
}
