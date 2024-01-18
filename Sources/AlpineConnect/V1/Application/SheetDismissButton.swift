//
//  SheetDismissButton.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 8/10/23.
//

import SwiftUI

public struct SheetDismissButton: View {
    
    var type: DismissType
    var additionalAction: (() -> Void)?
    
    public enum DismissType {
        case sheet
        case fullscreen
    }
    
    public init(_ type: DismissType = .sheet, addtionalAction: (() -> Void)? = nil) {
        self.type = type
        self.additionalAction = addtionalAction
    }
    
    public var body: some View {
        Button {
            switch type {
            case .fullscreen:
                AppControlOld.shared.showCover = false
            case.sheet:
                AppControlOld.shared.showSheet = false
            }
            
            if let additionalAction {
                additionalAction()
            }
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
