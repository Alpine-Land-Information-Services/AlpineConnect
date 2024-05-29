//
//  UpdateButton.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/7/22.
//

import SwiftUI

public struct UpdateButton: View {
    
    @ObservedObject var viewModel: SwiftUIUpdater
    @ObservedObject var control = AppControl.shared
        
    public init() {
        self.viewModel = SwiftUIUpdater()
    }
    
    public var body: some View {
        Button {
            viewModel.checkForUpdate(automatic: false)
        } label: {
            Text("Check for Update")
                .foregroundColor(.accentColor)
        }
        .onChange(of: viewModel.showAlert) { show in
            if show {
                viewModel.newAlert()
            }
        }
        .onChange(of: control.showAlert) { show in
            if !show {
                viewModel.showAlert = false
            }
        }
    }
}

struct UpdateButton_Previews: PreviewProvider {
    static var previews: some View {
        UpdateButton()
    }
}
