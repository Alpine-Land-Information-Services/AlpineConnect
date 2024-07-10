//
//  AppView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 10/14/22.
//

import SwiftUI
import AlpineUI
import AlpineCore

public struct AppView<App: View>: View {
    
    @ObservedObject var control = AppControlOld.shared
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    var app: App
    
    public init(@ViewBuilder app: () -> App) {
        self.app = app()
    }
    
    public var body: some View {
        app
            .onAppear {
                UIApplication.shared.addTapGestureRecognizer()
            }
            .popup(isPresented: $control.showSecondaryPopup, alignment: control.currentSecondaryPopup.alignment, direction: control.currentSecondaryPopup.direction) {
                control.currentSecondaryPopup.content
            }
            .overlay {
                if control.dimView {
                    dim
                }
            }
            .popup(isPresented: $control.showPopup, alignment: control.currentPopup.alignment, direction: control.currentPopup.direction) {
                control.currentPopup.content
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
            .fullScreenCover(isPresented: $control.showCover, content: {
                control.currentCover
                    .overlay {
                        if control.sheetDimView {
                            Color(uiColor: .black)
                                .opacity(0.4)
                                .ignoresSafeArea()
                        }
                    }
                    .popup(isPresented: $control.showSecondaryPopup, alignment: .bottom, direction: .bottomTrailing) {
                        control.currentSecondaryPopup.content
                    }
                    .appAlert(isPresented: $control.showSheetAlert, alert: control.currentAlert)
            })
            .ignoresSafeArea()
    }
    
    var dim: some View {
        Color(uiColor: .black)
            .opacity(0.4)
            .ignoresSafeArea()
    }
}
