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
                viewModel.checkForUpdate(automatic: automatic)
            }
            .alert(isPresented: $viewModel.showAlert) {
                viewModel.alert(dismissAction: dissmissAction)
            }
    }
}
