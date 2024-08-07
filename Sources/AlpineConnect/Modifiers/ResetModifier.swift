//
//  ResetModifier.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 3/7/24.
//

import SwiftUI
import AlpineCore
import PopupKit

struct ResetModifier: ViewModifier {
    
    var currentCode: String
    
    var core = CoreAppControl.shared
    
    func body(content: Content) -> some View {
        if core.defaults.resetCode != currentCode {
            Rectangle()
                .fill(.ultraThickMaterial)
                .ignoresSafeArea()
                .popupPresenter
                .onAppear {
                    checkToResetData()
                }
        }
        else {
            content
        }
    }
    
    func checkToResetData() {
        if FileManager.default.fileExists(atPath: FS.appDocumentsURL.appending(path: "Layers").path(percentEncoded: false)) {
            AppReset.forceReset(code: currentCode)
        }
        else if core.defaults.resetCode == nil {
            AppReset.setCode(currentCode)
        }
        
        AppReset.checkToReset(code: currentCode)
    }
}
