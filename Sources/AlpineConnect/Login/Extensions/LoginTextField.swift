//
//  LoginTextField.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/21/22.
//

import SwiftUI

struct LoginTextField: ViewModifier {
    let color: Color
    let padding: CGFloat
    let lineWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .overlay(RoundedRectangle(cornerRadius: padding)
                .stroke(color, lineWidth: lineWidth)
            )
            .frame(maxWidth: 400, minHeight: 40, alignment: .center)
            .background(Color.white)
            .foregroundColor(Color.black)
            .cornerRadius(10)
    }
}

extension View {
    func customTextField(color: Color = Color.gray, padding: CGFloat = 3, lineWidth: CGFloat = 0) -> some View {
        self.modifier(LoginTextField(color: color, padding: padding, lineWidth: lineWidth))
    }
}
