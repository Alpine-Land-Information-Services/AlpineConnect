//
//  ContentView.swift
//  ConnectTest
//
//  Created by Jenya Lebid on 4/6/22.
//

import SwiftUI
import AlpineConnect

//   600 - 10 min
//  3600 - 1 hour
// 86400 - 1 day

struct ContentView: View {
    var appViewModel = AppViewModel()
        
    init() {
        appViewModel.tracker.start(timeIntervalInSeconds: 3600)
    }
    
    var body: some View {
        UpdateButton()
        Text("")
            .modifier(NotificationCheckModifier(timeIntervalInSeconds: 600, actions: appViewModel.notificationActions))
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
