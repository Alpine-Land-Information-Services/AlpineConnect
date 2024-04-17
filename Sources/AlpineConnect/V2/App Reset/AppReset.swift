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
    // a: "Application Support"  in application's Library folder
    // s: "Sandbox Folder"       delete the whole app folder
    // d: "Documents"            in application's folder
    // p: "Preferences"          in application's Library folder
    // g: Application Group      in "group.com.alpinelis.atlas"
    
    private enum DeleteSource: String {
        case a
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Core.quit()
            }
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
        var urls = [URL]()
        switch source {
        case .s:
            var url = try? FileManager.default.url(for: .documentDirectory , in: .userDomainMask, appropriateFor: nil, create: false)
            urls.append(url)
            url = url?.deletingLastPathComponent()
            var urlFolder = url?.appending(component: "SystemData")
            urls.append(urlFolder)
            urlFolder = url?.appending(component: "tmp")
            urls.append(urlFolder)
            urlFolder = url?.appending(component: "Library")
            urls.append(urlFolder)
        case .d:
            let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            urls.append(url)
        case .p:
            var url = try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            url = url?.appending(component: "Preferences")
            urls.append(url)
        case .a:
            let url = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            urls.append(url)
        case .g:
            urls.append(FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alpinelis.atlas"))
        }
        
        for url in urls {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

public extension AppReset {
    
    static func forcedDeleteApplicationStorage() {
        delete(from: .s)
    } 
}
