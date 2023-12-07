//
//  UpdatableModifier.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/24/23.
//

import SwiftUI

struct UpdatableModifier: ViewModifier {
    
    @State var localID = UUID()
    var id: String
    
    func body(content: Content) -> some View {
        content
            .id(localID)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("View_Update"))) { id in
                guard let id = id.userInfo?.first?.value as? String else {
                    return
                }
                if id == self.id {
                    localID = UUID()
                }
            }
    }
}

public extension View {
    func updateable(_ id: String) -> some View {
        modifier(UpdatableModifier(id: id))
    }
}

public extension Notification {
    static func viewUpdate(with id: String) -> Notification {
        Notification(name: Notification.Name("View_Update"), object: nil, userInfo: ["id": id])
    }
}

