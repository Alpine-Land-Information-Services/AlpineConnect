//
//  LocationToggler.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/5/23.
//

import SwiftUI

struct LocationToggler: ViewModifier {
    
    @Environment(\.scenePhase) var scenePhase

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, newValue in
                switch newValue {
                case .active:
                    LocationManager.shared.resume()
                default:
                    LocationManager.shared.stopIfNoUsers()
                }
            }
    }
}

public extension View {
    
    var locationToggler: some View {
        modifier(LocationToggler())
    }
}
