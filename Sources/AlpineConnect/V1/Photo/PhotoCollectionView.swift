//
//  PhotoCollectionView.swift
//  Botany
//
//  Created by Jenya Lebid on 3/10/23.
//

import SwiftUI
import CoreData

import AlpineUI
import AlpineCore

public struct PhotoCollectionView: View {

    @EnvironmentObject var viewModel: PhotoViewModel
    @Environment(\.dismiss) var dismiss

    var interior = false

    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]

    public var body: some View {
        NavigationView {
            ScrollView {
                if !viewModel.gettingPhotos {
                    if viewModel.photos.isEmpty {
                        ContentUnavailableView("This \(viewModel.object.name) contains no photos.", systemImage: "photo")
                            .padding(.top, 100)
                    }
                    else {
                        photoGrid
                    }
                }
                else {
                    ProgressView("Loading Photos...")
                        .progressViewStyle(.circular)
                        .padding(.vertical, 200)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if !interior {
                        HStack {
                            PhotoButton()
                                .environmentObject(viewModel)
                                .disabled(viewModel.gettingPhotos)
                                .padding(.trailing)
                            DismissButton(environmentDismiss: false) {
                                dismiss()
                            }
                        }
                    }
                }
            }
            .background((Color(uiColor: .systemGray6)))
            .navigationTitle("\(viewModel.object.name) Photos")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .onAppear() {
            viewModel.loadPhotos()
        }
        .onDisappear {
            if !interior {
                viewModel.clearMemory()
            }
        }
    }

    var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(viewModel.photos) { photo in
                let container = Camera.containerSize(image: photo.image)

                NavigationLink(destination: {
                    Camera.PhotoView(photo: photo.image)
                }, label: {
                    VStack {
                        Image(uiImage: photo.image)
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                        Spacer()
                        HStack {
                            Text(photo.date.toString(format: "MMM d, HH:mm"))
                                .font(.caption)
                                .foregroundColor(Color(uiColor: .label))
                            Spacer()
                            Button {
                                viewModel.deletePhoto(photo)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(4)
                    }
                })
                .frame(width: container.width, height: container.height + 30)
                .background(
                    Color(uiColor: .systemGray6)
                        .shadow(radius: 2))
                .padding()
            }

        }
    }
}

public struct PhotoCollectionButton: View {

    @StateObject var viewModel: PhotoViewModel

    public init(object: PhotoObject) {
        self._viewModel = StateObject(wrappedValue: PhotoViewModel(object: object))
    }

    public var body: some View {
        Button {
            Core.presentSheet {
                PhotoCollectionView()
                    .environmentObject(viewModel)
            }
        } label: {
            Image(systemName: "photo.on.rectangle")
        }
    }
}

public struct PhotoCollectionBlock<Label: View>: View {
    
    @StateObject var viewModel: PhotoViewModel
    @Binding var changed: Bool

    var required: Bool
    var label: Label

    public init(object: PhotoObject, changed: Binding<Bool>, required: Bool = false, @ViewBuilder label: () -> Label) {
        self._viewModel = StateObject(wrappedValue: PhotoViewModel(object: object))
        self._changed = changed
        self.required = required
        self.label = label()
    }

    public var body: some View {
        Button {
            Core.presentSheet {
                PhotoCollectionView()
                    .environmentObject(viewModel)
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
