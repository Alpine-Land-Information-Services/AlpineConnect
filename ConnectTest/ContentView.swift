//
//  ContentView.swift
//  ConnectTest
//
//  Created by Jenya Lebid on 4/6/22.
//

import SwiftUI
import AlpineConnect

struct ContentView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .modifier(UpdateCheck(appName: "WBIS", automatic: false))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
