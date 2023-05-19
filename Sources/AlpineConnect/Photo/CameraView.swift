//
//  CameraView.swift
//  Botany
//
//  Created by Jenya Lebid on 3/10/23.
//

import SwiftUI

public struct CameraView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: PhotoViewModel
    
    public init() {}
            
    public var body: some View {
        ZStack(alignment: .trailing) {
            CameraRepresentable(viewModel: viewModel)
            VStack {
                backButton
                Spacer()
                photoButton
                Spacer()
                galleryButton
            }
            .padding()
        }
    }
    
    public var photoButton: some View {
        Button {
            viewModel.takePhoto()
        } label: {
            ZStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.white)
            }
            .overlay {
                if viewModel.takingPhoto {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .disabled(viewModel.takingPhoto)
        }
    }
    
    var galleryButton: some View {
        Button {
            viewModel.showGallery.toggle()
        } label: {
            Image(systemName: "photo.on.rectangle.angled")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 50, maxHeight: 50)
        }
        .disabled(viewModel.takingPhoto)
        .sheet(isPresented: $viewModel.showGallery) {
            PhotoCollectionView(interior: true)
                .environmentObject(viewModel)
        }
    }
    
    var backButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Done")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(Color.accentColor.opacity(0.75))
                .cornerRadius(10)
        }
        .disabled(viewModel.takingPhoto)
    }
}

//struct CameraGallery: View {
//
//    @EnvironmentObject var viewModel: CameraViewModel
//
//    let columns = [
//        GridItem(.adaptive(minimum: 200))
//    ]
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                LazyVGrid(columns: columns, spacing: 10) {
//                    ForEach(viewModel.photos) { photo in
//                        let container = Camera.containerSize(image: photo.image)
//
//                        NavigationLink(destination: {
//                            Camera.PhotoView(photo: photo.image)
//                        }, label: {
//                            VStack {
//                                Image(uiImage: photo.image)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .padding(2)
//                                Spacer()
//                                HStack {
//                                    Spacer()
//                                    Button {
//                                        viewModel.photos.removeAll(where: {$0.id == photo.id})
//                                    } label: {
//                                        Image(systemName: "trash")
//                                            .foregroundColor(.red)
//                                            .font(.caption)
//                                    }
//                                }
//                                .padding(4)
//                            }
//                        })
//                        .frame(width: container.width, height: container.height + 30)
//                        .background(
//                            Color(uiColor: .systemGray6)
//                                .shadow(radius: 2))
//                        .padding()
//                    }
//                }
//            }
//            .navigationBarTitle("Taken Photos")
//        }
//        .navigationViewStyle(.stack)
//    }
//}

//struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraView()
//    }
//}
