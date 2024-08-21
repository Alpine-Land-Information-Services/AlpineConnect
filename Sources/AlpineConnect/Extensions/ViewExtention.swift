//
//  File.swift
//  
//
//  Created by Vladislav on 7/10/24.
//

import Foundation
import SwiftUI

public extension View {
    
    var locationToggler: some View {
        modifier(LocationToggler())
    }
    
    var locationRequirementTracker: some View {
        modifier(LocationRequirementModifier())
    }
    
    func connectAlert(_ alert: ConnectAlert, isPresented: Binding<Bool>) -> some View {
        modifier(AlertModifier(isPresented: isPresented, alert: alert))
    }
    
    func alpineLoginSheet(info: LoginConnectionInfo, isPresented: Binding<Bool>, afterSignInAction: @escaping () async -> Void) -> some View {
        modifier(AlpineLoginSheet(isPresented: isPresented, info: info, afterSignInAction: afterSignInAction))
    }
    
    func appResetCheck(code: String) -> some View {
        modifier(ResetModifier(currentCode: code))
    }
    
    func changelog(appURL: URL, onVersionChange: @escaping () -> Void) -> some View {
        modifier(ChangeLogModifier(appURL: appURL, onVersionChange: onVersionChange))
    }
    
    func updateChecker(DBPassword: String, onDismiss: @escaping () -> Void) -> some View {
        modifier(UpdateCheckModifier(automatic: true, dismissAction: onDismiss, DBPassword: DBPassword))
    }
}
