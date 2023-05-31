//
//  PhotoCollectionView.swift
//  Botany
//
//  Created by Jenya Lebid on 3/10/23.
//

import SwiftUI

public struct PhotoCollectionView: View {
    
    @EnvironmentObject var viewModel: PhotoViewModel
        
    var interior = false
    
    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]
        
    public var body: some View {
        NavigationView {
            ScrollView {
                if !viewModel.gettingPhotos {
                    photoGrid
                }
                else {
                    ProgressView("Loading Photos...")
                        .progressViewStyle(.circular)
                        .padding(.vertical, 200)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !interior {
                        PhotoButton()
                            .environmentObject(viewModel)
                    }
                }
            }
            .background((Color(uiColor: .systemGray6)))
            .navigationTitle("\(viewModel.object.name) Photos")
        }
        .navigationViewStyle(.stack)
        .onAppear() {
            viewModel.loadPhotos()
        }
        .onWillDisappear {
            viewModel.clearMemory()
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
            AppControl.showSheet(view: PhotoCollectionView().environmentObject(viewModel))
        } label: {
            Image(systemName: "photo.on.rectangle")
        }
    }
}

public struct PhotoCollectionBlock<Label: View>: View {
    
    @StateObject var viewModel: PhotoViewModel
    
    var required: Bool
    var label: Label

    public init(object: PhotoObject, required: Bool = false, @ViewBuilder label: () -> Label) {
        self._viewModel = StateObject(wrappedValue: PhotoViewModel(object: object))
        self.required = required
        self.label = label()
    }

    public var body: some View {
        Button {
            AppControl.showSheet(view: PhotoCollectionView().environmentObject(viewModel))
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
    }
}

//struct PhotoCollectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoCollectionView()
//    }
//}
