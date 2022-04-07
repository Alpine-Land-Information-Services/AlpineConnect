//
//  UpdateButton.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/7/22.
//

import SwiftUI

public struct UpdateButton: View {
    
    @ObservedObject var viewModel: SwiftUIUpdater
    
    var appName: String
    
    public init(appName: String) {
        self.appName = appName
        self.viewModel = SwiftUIUpdater(appName: appName)
    }
    
    public var body: some View {
        Button {
            viewModel.checkForUpdate(automatic: false)
        } label: {
            Text("Check Update")
        }
        .alert(isPresented: $viewModel.showAlert) {
            viewModel.alert()
        }
    }
}

struct UpdateButton_Previews: PreviewProvider {
    static var previews: some View {
        UpdateButton(appName: "WBIS")
    }
}
