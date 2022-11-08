//
//  AppView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 10/14/22.
//

import SwiftUI
import AlpineUI

public struct AppView<App: View>: View {
    
    @ObservedObject var control = AppControl.shared
    
    var app: App
    
    public init(@ViewBuilder app: () -> App) {
        self.app = app()
    }
    
    public var body: some View {
        app
            .popup(isPresented: $control.showSecondaryPopup, alignment: control.currentSecondaryPopup.alignment, direction: control.currentSecondaryPopup.direction) {
                control.currentSecondaryPopup.view
            }
            .overlay {
                if control.dimView {
                    dim
                }
            }
            .popup(isPresented: $control.showPopup, alignment: control.currentPopup.alignment, direction: control.currentPopup.direction) {
                control.currentPopup.view
            }
            .appAlert(isPresented: $control.showRegularAlert, alert: control.currentAlert)
            .sheet(isPresented: $control.showSheet) {
                control.currentSheet
                    .overlay {
                        if control.sheetDimView {
                            Color(uiColor: .black)
                                .opacity(0.4)
                                .ignoresSafeArea()
                        }
                    }
                    .appAlert(isPresented: $control.showSheetAlert, alert: control.currentAlert)
            }
            .ignoresSafeArea()
    }
    
    var dim: some View {
        Color(uiColor: .black)
            .opacity(0.4)
            .ignoresSafeArea()
    }
}
