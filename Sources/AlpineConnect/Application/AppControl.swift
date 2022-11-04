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
    @Published public var showBottomPopup = false
    
    @Published public var currentAlert = AppAlert(title: "", message: "", dismiss: AlertAction(text: ""), actions: [])
    @Published public var currentSheet = AnyView(EmptyView())
    @Published public var currentPopup = AnyView(EmptyView())
    
    @Published public var currentBottomPopup = AnyView(EmptyView())
    
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
    
    public func showBottom() {
        withAnimation {
            showBottomPopup.toggle()
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
}
