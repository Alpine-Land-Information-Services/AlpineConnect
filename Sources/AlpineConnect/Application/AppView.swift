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
            .overlay {
                if control.dimView {
                    dim
                }
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
            .popup(isPresented: control.showPopup) {
                control.currentPopup
            }
            .popup(isPresented: control.showBottomPopup, alignment: .bottom, direction: .bottom) {
                control.currentBottomPopup
            }
    }
    
    var dim: some View {
        Color(uiColor: .black)
            .opacity(0.4)
            .ignoresSafeArea()
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AppView {
            EmptyView()
        }
    }
}
