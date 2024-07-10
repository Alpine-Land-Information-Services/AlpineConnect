//
//  AlertModifier.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/8/23.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    
    var alert: ConnectAlert
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .alert(alert.title, isPresented: $isPresented, actions: {
                if let textFieldBinding = alert.textFieldBinding {
                    TextField(alert.textFieldPlaceholder ?? "", text: textFieldBinding)
                }
                if let buttons = alert.buttons {
                    ForEach(buttons, id: \.label) { button in
                        Button(role: button.role) {
                            button.action()
                        } label: {
                            Text(button.label)
                        }
                    }
                }
                if let button = alert.dismissButton {
                    Button(role: button.role) {
                        button.action()
                    } label: {
                        Text(button.label)
                    }
                } else {
                    Button(role: .cancel) {
                        
                    } label: {
                        Text("Okay")
                    }
                }
            }, message: {
                if let message = alert.message {
                    Text(message)
                }
            })
    }
}
