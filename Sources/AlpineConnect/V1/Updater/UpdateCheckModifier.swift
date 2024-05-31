//
//  UpdateCheckModifier.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/6/22.
//

import SwiftUI

public struct UpdateCheckModifier: ViewModifier {
    
    @StateObject var viewModel = SwiftUIUpdater()
    
    var automatic: Bool
    var dismissAction: () -> ()
    
    public init(automatic: Bool, dismissAction: @escaping () -> (), DBPassword: String) {
        self.automatic = automatic
        self.dismissAction = dismissAction
        TrackerConnectionInfo.shared.password = DBPassword
    }
    
    public func body(content: Content) -> some View {
        content
            .task {
                viewModel.checkForUpdate(automatic: automatic, onComplete: dismissAction)
            }
            .alert(isPresented: $viewModel.showAlert) {
                viewModel.alert(dismissAction: dismissAction)
            }
    }
}

extension View {
    
    func updateChecker(DBPassword: String, onDismiss: @escaping () -> Void) -> some View {
        modifier(UpdateCheckModifier(automatic: true, dismissAction: onDismiss, DBPassword: DBPassword))
    }
}
