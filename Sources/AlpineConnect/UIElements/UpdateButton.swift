//
//  UpdateButton.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/7/22.
//

import SwiftUI

public struct UpdateButton: View {
    
    @StateObject var viewModel = SwiftUIUpdater()
        
    public init() {}
    
    public var body: some View {
        Button {
            viewModel.checkForUpdate(automatic: false, onComplete: {})
        } label: {
            Label("Check Updates", systemImage: "arrow.down.app")
        }
        .onChange(of: viewModel.showAlert) { _, show in
            if show {
                viewModel.newAlert()
            }
        }
    }
}
