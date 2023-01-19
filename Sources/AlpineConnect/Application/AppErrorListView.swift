//
//  AppErrorListView.swift
//  
//
//  Created by Jenya Lebid on 1/19/23.
//

import SwiftUI
import AlpineUI
import CoreData

public struct AppErrorListView: View {
    
    @FetchRequest private var errors: FetchedResults<AppError>

    public init() {
        self._errors = FetchRequest(entity: NSEntityDescription.entity(forEntityName: "AppError", in: .main())!, sortDescriptors: [NSSortDescriptor(keyPath: \AppError.date, ascending: false)], animation: .default)
    }
    
    public var body: some View {
        List {
            ForEach(errors) { error in
                NavigationLink {
                    AppErrorView(error: error)
                } label: {
                    HStack {
                        Text(error.onAction!)
                            .font(.callout)
                        Spacer()
                        Text(error.date!.toString(format: "MMM d"))
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .systemGray))
                    }
                }
            }
        }
        .navigationTitle("Error Logs")
    }
}

struct AppErrorListView_Previews: PreviewProvider {
    static var previews: some View {
        AppErrorListView()
    }
}
