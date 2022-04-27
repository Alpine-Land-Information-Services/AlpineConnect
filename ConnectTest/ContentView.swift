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
    @ObservedObject var updater = SwiftUIUpdater()

    var appViewModel = AppViewModel()
        
    init() {
        
    }
    
    var body: some View {
//        Text("HELLO")
        UpdateButton()

    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
