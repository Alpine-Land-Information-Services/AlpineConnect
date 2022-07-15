//
//  LoginTextField.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/21/22.
//

import SwiftUI

struct LoginTextField: ViewModifier {
    
    let color: Color = .gray
    let padding: CGFloat = 6
    let lineWidth: CGFloat = 0
    
    var placeholder: String
    
    @Binding var value: String
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .overlay(RoundedRectangle(cornerRadius: padding)
                .stroke(color, lineWidth: lineWidth)
            )
            .modifier(PlaceholderStyle(showPlaceHolder: value.isEmpty, placeholder: placeholder))
            .frame(height: 40)
            .frame(maxWidth: 400, alignment: .center)
            .background(Color.white)
            .foregroundColor(Color.black)
            .cornerRadius(10)
    }
}

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                .padding(.horizontal, 10)
                .foregroundColor(Color.gray)
                .font(.callout)
            }
            content
            .foregroundColor(Color.black)
            .padding(5.0)
        }
    }
}

extension View {
    func loginField(placeholder: String, value: Binding<String>) -> some View {
        self.modifier(LoginTextField(placeholder: placeholder, value: value))
    }
}
