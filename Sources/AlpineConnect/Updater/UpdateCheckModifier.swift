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
    
    public init(automatic: Bool, DBPassword: String) {
        self.automatic = automatic
        TrackerConnectionInfo.shared.password = DBPassword
    }
    
    public func body(content: Content) -> some View {
        content
            .task {
                viewModel.checkForUpdate(automatic: automatic)
            }
            .alert(isPresented: $viewModel.showAlert) {
                viewModel.alert()
            }
    }
}
