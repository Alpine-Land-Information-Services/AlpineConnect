//
//  PhotoCollectionButton.swift
//  
//
//  Created by Vladislav on 7/18/24.
//

import SwiftUI
import AlpineCore

public struct PhotoCollectionButton: View {

    @State var viewModel: PhotoViewModel

    public init(object: PhotoObject) {
        self._viewModel = State(wrappedValue: PhotoViewModel(object: object))
    }

    public var body: some View {
        Button {
            Core.presentSheet {
                PhotoCollectionView()
                    .environment(viewModel)
            }
        } label: {
            Label("Photos", systemImage: "photo.on.rectangle")
        }
    }
}

public struct PhotoCollectionBlock<Label: View>: View {
    
    @State var viewModel: PhotoViewModel
    
    @Binding var changed: Bool

    var required: Bool
    var label: Label

    public init(object: PhotoObject, changed: Binding<Bool>, required: Bool = false, @ViewBuilder label: () -> Label) {
        self._viewModel = State(wrappedValue: PhotoViewModel(object: object))
        self._changed = changed
        self.required = required
        self.label = label()
    }

    public var body: some View {
        Button {
            Core.presentSheet {
                PhotoCollectionView()
                    .environment(viewModel)
            }
        } label: {
            label
                .overlay {
                    if required && viewModel.photos.isEmpty {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke()
                            .foregroundColor(.red)
                    }
                }
        }
        .onChange(of: viewModel.takingPhoto) { _, taking in
            if !taking {
                changed.toggle()
            }
        }
    }
}
