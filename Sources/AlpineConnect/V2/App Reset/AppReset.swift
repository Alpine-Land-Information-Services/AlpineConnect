//
//  AppReset.swift
//  AlpineConnect
//
//  Created by mkv on 1/31/24.
//

import Foundation
import AlpineCore

public class AppReset {
    
    // "code_s.d.p.g"
    // delete files from:
    // s: "Sandbox Folder"       delete the whole app folder
    // d: "Documents"            in application's folder
    // p: "Preferences"          in application's Library folder
    // g: Application Group      in "group.com.alpinelis.atlas"
    
    private enum DeleteSource: String {
        case s
        case d
        case p
        case g
    }
    
    static var core: CoreAppControl {
        CoreAppControl.shared
    }
    
    private static var currectAppResetCode = ""
    
    public static func checkToReset(code: String) {
        currectAppResetCode = code
        
        if let code = core.defaults.resetCode {
            guard code != currectAppResetCode else { return }
            createResetAlert()
        }
        else {
            createResetAlert()
        }
    }
    
    public static func forceReset(code: String) {
        currectAppResetCode = code
        createResetAlert()
    }
    
    public static func setCode(_ code: String) {
        guard code != core.defaults.resetCode else { return }

        core.defaults.resetCode = code
    }
}

private extension AppReset {
    
    static func createResetAlert() {
        let alert = CoreAlert(title: "App Reset Required", message: "This update requires clearning all of your application data.",
                              buttons: [CoreAlertButton(title: "Clear", style: .destructive, action: {
            performReset()
        })])
        Core.makeAlert(alert)
    }
    
    static func resetComplete() {
        let alert = CoreAlert(title: "Reset Successful", message: "Application restart required to continue.",
                              buttons: [CoreAlertButton(title: "Quit App", action: {
            
            core.defaults.resetWithCode(currectAppResetCode)
            exit(0)
        })])
        Core.makeAlert(alert)
    }
    
    static func performReset() {
        let components = currectAppResetCode.components(separatedBy: "_")
        if components.count == 2 {
            let deletion = components[1].components(separatedBy: ".")
            for item in deletion {
                if let source = DeleteSource(rawValue: item) {
                    delete(from: source)
                }
            }
            resetComplete()
        }
    }
    
    private static func delete(from source: DeleteSource) {
        var url: URL?
        switch source {
        case .s:
            url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            url = url?.deletingLastPathComponent()
        case .d:
            url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .p:
            url = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            url = url?.appending(component: "Preferences")
        case .g:
            url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alpinelis.atlas")
        }
        if let url {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
