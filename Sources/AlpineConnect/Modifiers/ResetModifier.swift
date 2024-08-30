//
//  ResetModifier.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 3/7/24.
//

import SwiftUI
import AlpineCore

struct ResetModifier: ViewModifier {
    
    var core = CoreAppControl.shared
    var currentCode: String
    
    func body(content: Content) -> some View {
        if core.defaults.resetCode != currentCode {
            Rectangle()
                .fill(.ultraThickMaterial)
                .ignoresSafeArea()
                .popupPresenter
                .onAppear {
                    checkToResetData()
                }
        } else {
            content
        }
    }
    
    private func checkToResetData() {
        if FileManager.default.fileExists(atPath: FS.appDocumentsURL.appending(path: "Layers").path(percentEncoded: false)) {
            AppReset.forceReset(code: currentCode)
        }
        else if core.defaults.resetCode == nil {
            AppReset.setCode(currentCode)
        }
        
        AppReset.checkToReset(code: currentCode)
    }
}
