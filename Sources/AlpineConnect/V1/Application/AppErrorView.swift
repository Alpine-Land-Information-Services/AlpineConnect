//
//  AppErrorView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/19/23.
//

import SwiftUI

struct AppErrorView: View {
    
    var error: ApplicationError
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Log:")
                        .font(.subheadline)
                    Spacer()
                    Text(error.date.toString(format: "MMM d, h:mm a"))
                        .font(.caption)
                }
                Divider()
                    .padding(6)
                Text(error.systemLog ?? "No logged message." + "\n" + (error.additionalInfo ?? "No additional information."))
            }
            .padding()
        }
        .navigationTitle(error.onAction ?? "No action specified")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ReportIssueView(userName: CurrentUser.fullName, email: CurrentUser.email, title: error.onAction ?? "", text: (error.systemLog ?? "") + "\n" + (error.additionalInfo ?? "No additional information."))) {
                    Label("Report", systemImage: "ladybug")
                        .labelStyle(.titleAndIcon)
                        .foregroundColor(.orange)
                }
            }
        }
    }
}

//struct AppErrorView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppErrorView()
//    }
//}
