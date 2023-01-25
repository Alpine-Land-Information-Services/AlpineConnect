//
//  SwiftUIView.swift
//
//
//  Created by Jenya Lebid on 1/25/23.
//

import SwiftUI
import AlpineUI

struct DBRescueView: View {
    
    @ObservedObject var viewModel = DBRescueViewModel.shared
    
    var body: some View {
        NavigationBlock(title: "Database Initialization Failed", mode: .large) {
            BetterList {
                ForEach(viewModel.failedDB) { db in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("The following database container could not be loaded into application:")
                        Divider()
                        HStack {
                            HStack {
                                Image(systemName: "server.rack")
                                    .font(.title)
                                Text(db.container.name)
                            }
                            .padding()
                            Divider()
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 8, alignment: .leading)]) {
                                ForEach(db.containedItems, id: \.self) { item in
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .font(.caption)
                                        Text(item)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        Group {
                            Text("Error:")
                                .font(.headline)
                            ScrollView {
                                Text(db.error)
                                    .padding(8)
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke()
                            )
                        }
                        .padding(.leading)
                        Divider()
                            .padding()
                        Text("Possible Actions:")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                TextButtonBlock(text: "Reset Container", action: {
                                    db.resetAction()
                                })
                                TextButtonBlock(text: "Upload & Reset", action: {
                                    
                                })
                                .disabled(true)
                                TextButtonBlock(text: "Upload & Use Backup", action: {
                                    
                                })
                                .disabled(true)
                                TextButtonBlock(text: "Upload & Quit", action: {
                                    
                                })
                                .disabled(true)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(10)
                .padding()
            }
            .interactiveDismissDisabled(true)
            .background(Color(uiColor: .systemGray6))

        }
    }
}

struct DBRescueView_Previews: PreviewProvider {
    static var previews: some View {
        DBRescueView()
    }
}
