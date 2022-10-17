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
    
    @Published public var currentAlert = AppAlert(title: "", message: "", dismiss: AlertAction(text: ""), actions: [])
    @Published public var currentSheet = AnyView(EmptyView())
    @Published public var currentPopup = AnyView(EmptyView())
    
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
    
    func determineAlertType() {

    }
}
