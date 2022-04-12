//
//  NotificationCheckModifier.swift
//  AlpineConnect
//
//  Created by mkv on 4/12/22.
//

import SwiftUI

public struct NotificationCheckModifier: ViewModifier {
    
    @ObservedObject var viewModel: SwiftUINotifier
    var checkInterval: TimeInterval = 10
    
    public init(timeIntervalInSeconds: TimeInterval = 10.0, actions: @escaping(String)->Void) {
        viewModel = SwiftUINotifier()
        viewModel.actions = actions
        checkInterval = timeIntervalInSeconds
    }
    
    public func body(content: Content) -> some View {
        content
            .task {
                viewModel.check(timeIntervalInSeconds: checkInterval)
            }
            .alert(isPresented: $viewModel.showAlert) {
                viewModel.alert()
            }
    }
}
