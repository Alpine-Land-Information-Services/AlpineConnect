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
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(uiColor: .systemGray))
                        Divider()
                        HStack {
                            HStack {
                                Image(systemName: "server.rack")
                                    .font(.title)
                                    .foregroundColor(Color.accentColor)
                                Text(db.container.name)
                            }
                            .padding()
                            Divider()
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 12, alignment: .leading)]) {
                                ForEach(db.containedItems, id: \.self) { item in
                                    HStack {
                                        Image(systemName: "circle.fill")
                                            .font(.caption2)
                                            .foregroundColor(Color.accentColor)
                                        Text(item)
                                            .font(.caption)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        Divider()
                        HStack {
                            Text("Error:")
                                .font(.headline)
                                .padding(.leading)
                            Text(db.error.localizedDescription)
                                .font(.callout)
                        }
                        .padding(.top)
                        Divider()
                            .padding()
                        Text("Possible Actions:")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                TextButtonBlock(text: "Reset Container", action: {
                                    viewModel.resetCointainer(db.container)
                                })
                                TextButtonBlock(text: "Upload & Create New Container", destination: {
                                    DBUploadView(container: db)
                                })
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
