//
//  SheetDismissButton.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 8/10/23.
//

import SwiftUI

public struct SheetDismissButton: View {
    
    public init() {}
    
    public var body: some View {
        Button {
            AppControl.shared.showSheet = false
        } label: {
            Label("Dismiss", systemImage: "xmark")
                .foregroundColor(.red)
        }
    }
}

struct SheetDismissButton_Previews: PreviewProvider {
    static var previews: some View {
        SheetDismissButton()
    }
}
