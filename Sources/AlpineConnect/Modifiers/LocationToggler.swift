//
//  LocationToggler.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/5/23.
//

import SwiftUI
import AlpineCore

struct LocationToggler: ViewModifier {
    
    @Environment(\.scenePhase) var scenePhase

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, newValue in
                switch newValue {
                case .active:
                    LocationManager.shared.resume()
                    Core.shared.markActive()
                    Core.makeEvent("application in foreground", type: .userAction)
                default:
                    LocationManager.shared.stopIfNoUsers()
                    Core.shared.markInactive()
                    Core.makeEvent("application in background", type: .userAction)
                }
            }
    }
}

public extension View {
    
    var locationToggler: some View {
        modifier(LocationToggler())
    }
}
