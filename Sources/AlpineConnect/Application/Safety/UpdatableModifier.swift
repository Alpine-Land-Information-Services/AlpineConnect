//
//  UpdatableModifier.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/24/23.
//

import SwiftUI

struct UpdatableModifier: ViewModifier {
    
    @State var localID = UUID()

    func body(content: Content) -> some View {
        content
            .id(localID)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("Connect-Refresh"))) { _ in
                localID = UUID()
            }
    }
}

public extension View {
    var updatable: some View {
        modifier(UpdatableModifier())
    }
}

