//
//  UpdateButton.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/7/22.
//

import SwiftUI

public struct UpdateButton: View {
    
    @ObservedObject var viewModel: SwiftUIUpdater
        
    public init() {
        self.viewModel = SwiftUIUpdater()
    }
    
    public var body: some View {
        Button {
            viewModel.checkForUpdate(automatic: false)
        } label: {
            Text("Check Update")
        }
        .alert(isPresented: $viewModel.showAlert) {
            viewModel.alert(dismissAction: {})
        }
    }
}

struct UpdateButton_Previews: PreviewProvider {
    static var previews: some View {
        UpdateButton()
    }
}
