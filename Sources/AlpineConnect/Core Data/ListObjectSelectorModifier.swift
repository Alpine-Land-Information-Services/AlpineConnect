//
//  ListObjectSelectorModifier.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 3/6/23.
//

import SwiftUI

struct ListObjectSelectorModifier<Destination: View>: ViewModifier {
    
    var name: String
    
    @State var open: Bool = false
    
    @State var destination: Destination
    @State var action: (() -> ())?
    
    init(_ name: String, @ViewBuilder destination: () -> Destination, action: (() -> ())?) {
        self.name = name
        self._destination = State(wrappedValue: destination())
        if let action {
            self._action = State(wrappedValue: action)
        }
    }
    
    func body(content: Content) -> some View {
        ScrollViewReader { value in
            content
                .onAppear {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        checkAndOpen(proxy: value)
//                    }
                }
                .background(
                    NavigationLink(isActive: $open, destination: {
                        destination
                    }, label: {
                        EmptyView()
                    })
                )
        }
    }
    
    func checkAndOpen(proxy: ScrollViewProxy) {
        if let object = ListObjectSelector.object(with: name) {
            proxy.scrollTo(object.guid, anchor: .center)
            if let action {
                action()
            }
            else {
                open = true
            }
            NotificationCenter.default.post(name: Notification.Name("ListItemSelect"), object: nil, userInfo: ["id": object.guid])
            ListObjectSelector.removeObject(with: name)
        }
    }
}

public extension View {
    func listObjectOpener<Destination: View>(for name: String, @ViewBuilder destination: () -> Destination = {EmptyView()}, action: (() -> ())? = nil) -> some View {
        modifier(ListObjectSelectorModifier(name, destination: destination, action: action))
    }
}
