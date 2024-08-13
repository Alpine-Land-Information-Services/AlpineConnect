//
//  AppErrorView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/19/23.
//

//import SwiftUI
//
//struct AppErrorView: View {
//    
//    var error: AppError
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                HStack {
//                    Text("Log:")
//                        .font(.subheadline)
//                    Spacer()
//                    Text(error.date!.toString(format: "MMM d, h:mm a"))
//                        .font(.caption)
//                }
//                Divider()
//                    .padding(6)
//                Text(error.log! + "\n" + (error.customDescription ?? "No additional information."))
//            }
//            .padding()
//        }
//        .navigationTitle(error.onAction!)
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                NavigationLink(destination: ReportIssueView(userName: Connect.user!.fullName, email: Connect.user!.email, title: error.onAction ?? "", text: (error.log ?? "") + "\n" + (error.customDescription ?? "No additional information."))) {
//                    Label("Report", systemImage: "ladybug")
//                        .labelStyle(.titleAndIcon)
//                        .foregroundColor(.orange)
//                }
//            }
//        }
//    }
//}

//struct AppErrorView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppErrorView()
//    }
//}
