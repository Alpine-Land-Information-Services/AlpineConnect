//
//  LocationToggler.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/5/23.
//

import SwiftUI

struct LocationToggler: ViewModifier {
    
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var location = Location.shared

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { newValue in
                switch newValue {
                case .active:
                    Location.shared.resume()
                default:
                    if Location.shared.locationUsers.isEmpty {
                        Location.shared.stop()
                    }
                }
            }
    }
}

public extension View {
    
    var locationToggler: some View {
        modifier(LocationToggler())
    }
}
