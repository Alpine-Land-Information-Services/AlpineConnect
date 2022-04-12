//
//  UpdateCheckModifier.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/6/22.
//

import SwiftUI

public struct UpdateCheckModifier: ViewModifier {
    
    @ObservedObject var viewModel: SwiftUIUpdater
    
    var appName: String
    var automatic: Bool
    
    public init(appName: String, automatic: Bool) {
        self.appName = appName
        self.automatic = automatic
        self.viewModel = SwiftUIUpdater()
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
