//
//  ContentView.swift
//  ConnectTest
//
//  Created by Jenya Lebid on 4/6/22.
//

import SwiftUI
import AlpineConnect

struct ContentView: View {
    var appViewModel = AppViewModel()
        
    init() {
        Tracker.start()
    }
    
    var body: some View {
        UpdateButton()
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//            .modifier(UpdateCheck(appName: "WBIS", automatic: false))
            .modifier(NotificationCheckModifier(timeIntervalInSeconds: 20, actions: appViewModel.notificationActions))
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
