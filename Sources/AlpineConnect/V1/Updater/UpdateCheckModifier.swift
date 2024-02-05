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
    var dissmissAction: () -> ()
    
    public init(automatic: Bool, dismissAction: @escaping () -> (), DBPassword: String) {
        self.automatic = automatic
        self.dissmissAction = dismissAction
        TrackerConnectionInfo.shared.password = DBPassword
    }
    
    public func body(content: Content) -> some View {
        content
            .task {
                viewModel.checkForUpdate(automatic: automatic, onComplete: dissmissAction)
            }
            .alert(isPresented: $viewModel.showAlert) {
                viewModel.alert(dismissAction: dissmissAction)
            }
    }
}

extension View {
    
    func updateChecker(DBPassword: String, onDismiss: @escaping () -> Void) -> some View {
        modifier(UpdateCheckModifier(automatic: true, dismissAction: onDismiss, DBPassword: DBPassword))
    }
}
