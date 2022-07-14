//
//  SpinnerButton.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 7/13/22.
//

import SwiftUI

struct SpinnerButton: View {
    
    var label: String
    var action: () -> ()
    var isDisabled: Bool
    
    @Binding var activated: Bool
    
    var body: some View {
        Button {
            action()
        } label: {
            if activated {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            else {
                Text(label)
                    .frame(maxWidth: .infinity)
            }
        }
        .font(.headline)
        .padding()
        .foregroundColor(Color.white)
        .frame(maxWidth: .infinity)
        .background(Color.accentColor)
        .cornerRadius(10)
        .padding()
        .disabled(isDisabled)
    }
}

struct SpinnerButton_Previews: PreviewProvider {
    static var previews: some View {
        SpinnerButton(label: "Go", action: {}, isDisabled: false, activated: .constant(true))
    }
}
