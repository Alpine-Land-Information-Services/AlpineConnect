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
    
    @Published public var currentAlert = AppAlert(title: "", message: "", dismiss: AlertAction(text: ""), actions: [])
    @Published public var currentSheet = AnyView(EmptyView())
    
    @Published public var currentPopup = AppPopup {AnyView(EmptyView())}
    @Published public var currentSecondaryPopup = AppPopup {AnyView(EmptyView())}
        
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


//MARK: Alerts
extension AppControl {
    
    public func noConnectionAlert() {
        let alert = AppAlert(title: "Offline", message: "You are not connected to network, please connect to proceed.")
        toggleAlert(alert)
    }
    
    public func toggleAlert(_ alert: AppAlert) {
        guard !showAlert else {
            return
        }
        
        DispatchQueue.main.async {
            self.currentAlert = alert
            withAnimation {
                self.showAlert.toggle()
            }
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
}
