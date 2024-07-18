//
//  NotificationCheckModifier.swift
//  AlpineConnect
//
//  Created by mkv on 4/12/22.
//

import SwiftUI

public struct NotificationCheckModifier: ViewModifier {
    
    @ObservedObject var viewModel: SwiftUINotifier
    var checkInterval: TimeInterval
    
    public init(timeIntervalInSeconds: TimeInterval, actions: ((String) -> Void)?) {
        checkInterval = timeIntervalInSeconds
        viewModel = SwiftUINotifier(actions: actions)
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
