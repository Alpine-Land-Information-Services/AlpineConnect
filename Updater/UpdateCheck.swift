//
//  UpdaterView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/6/22.
//

import SwiftUI

public struct UpdateCheck: ViewModifier {
    
    @State var showAlert = false
    @ObservedObject var viewModel: UpdaterViewModel
    
    var appName: String
    var automatic: Bool
    
    public init(appName: String, automatic: Bool) {
        self.appName = appName
        self.automatic = automatic
        self.viewModel = UpdaterViewModel(appName: appName)
    }
    
    public func body(content: Content) -> some View {
        content
            .task {
                viewModel.checkForUpdate(name: appName, automatic: automatic, showMessage: { result in
                    if result {
                        DispatchQueue.main.async {
                            viewModel.getUpdateStatus()
                            if !automatic {
                                showAlert = true
                            }
                        }
                    }
                })
            }
            .alert(isPresented: $showAlert) {
                viewModel.alert()
            }
    }
}
