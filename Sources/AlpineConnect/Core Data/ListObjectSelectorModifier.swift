//
//  ListObjectSelectorModifier.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 3/6/23.
//

import SwiftUI

struct ListObjectSelectorModifier: ViewModifier {
    
//    var name: String
    
//    @State var open: Bool = false
//
//    @State var destination: Destination
//    @State var action: (() -> ())?
    
//    init(_ name: String, @ViewBuilder destination: () -> Destination, action: (() -> ())?) {
//        self.name = name
//        self._destination = State(wrappedValue: destination())
//        if let action {
//            self._action = State(wrappedValue: action)
//        }
//    }
    
    func body(content: Content) -> some View {
        ScrollViewReader { value in
            content
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ListItemSelect"))) { info in
                    if let id = info.userInfo?.first?.value as? UUID {
                        value.scrollTo(id, anchor: .center)
                    }
                }
        }
    }
    
//    func checkAndOpen(proxy: ScrollViewProxy) {
//        if let object = ListObjectSelector.object(with: name) {
//            proxy.scrollTo(object.guid, anchor: .center)
//            if let action {
//                action()
//            }
//            else {
//                open = true
//            }
//            NotificationCenter.default.post(name: Notification.Name("ListItemSelect"), object: nil, userInfo: ["id": object.guid])
//            ListObjectSelector.removeObject(with: name)
//        }
//    }
}

public extension View {
//    func listObjectOpener<Destination: View>(for name: String, @ViewBuilder destination: () -> Destination = {EmptyView()}, action: (() -> ())? = nil) -> some View {
//        modifier(ListObjectSelectorModifier(name, destination: destination, action: action))
//    }
    
    var listSelector: some View {
        modifier(ListObjectSelectorModifier())
    }
}
