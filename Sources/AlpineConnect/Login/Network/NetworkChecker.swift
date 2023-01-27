//
//  NetworkChecker.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/27/23.
//

import SwiftUI

struct NetworkCheckModifier: ViewModifier {
    
    @ObservedObject var network = NetworkMonitor.shared
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if !network.connected {
                    notConnected
                }
            }
    }
    
    var notConnected: some View {
        VStack {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.yellow)
                .frame(maxHeight: 140)
            Text("No Network")
                .font(.headline)
                .padding()
            Text("Active connection required to proceed.")
                .font(.caption)
                .foregroundColor(Color(uiColor: .systemGray))
                .padding(6)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}

extension View {
    
    public func networkChecker() -> some View {
        modifier(NetworkCheckModifier())
    }
}
