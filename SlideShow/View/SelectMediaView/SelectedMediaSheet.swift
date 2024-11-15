//
//  SelectedMediaSheet.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/19/24.
//

import SwiftUI
import Photos

struct SelectedMediaSheet: View {
    var size: Double
    @Binding var selectedMedias: [PHAsset]
    @Binding var selectedIdx: [Int]
    
    var body: some View {
        VStack {
            HStack {
                Text("Slideshow Duration \(timeString(selectedMedias.count))")
                    .font(.callout)
                    .bold()
                    .foregroundStyle(.black)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "shuffle")
                        .frame(height: 20)
                        .foregroundStyle(.black)
                }
                
                Spacer()
                    .frame(width: 10)
            }
            .padding(.horizontal)
            .offset(y: 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(Array(selectedMedias.enumerated()), id: \.1) { idx, image in
                        SelectedMedia(selectedMedias: $selectedMedias,
                                      selectedIdx: $selectedIdx,
                                      size: size,
                                      asset: image,
                                      idx: idx)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowBackground(accentColor(.accent))
                }
                .buttonStyle(PlainButtonStyle())
                .offset(y: -15)
                .scrollTargetLayout()
                .padding()
            }
            .scrollTargetBehavior(.viewAligned)
            .defaultScrollAnchor(.leading)
        }
    }
    
    func timeString(_ count: Int) -> String {
        let duration = 3 * count
        let hours = duration / 3600
        let mins = (duration % 3600) / 60
        let secs = (duration % 3600) % 60
        if hours > 0 {
            return String(format: "%.2d:%.2d:%.2d", hours, mins, secs)
        } else {
            return String(format: "%.2d:%.2d", mins, secs)
        }
    }
}

struct SelectedMedia: View {
    @Binding var selectedMedias: [PHAsset]
    @Binding var selectedIdx: [Int]
    var size: Double
    let asset: PHAsset
    @State var image: UIImage?
    var idx: Int
    
    var body: some View {
        Image(uiImage: image ?? UIImage())
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size, alignment: .center)
            .clipped()
            .cornerRadius(5)
            .overlay {
                Button {
                    selectedMedias.remove(at: idx)
                    selectedIdx.remove(at: idx)
                } label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundStyle(.black)
                        .background(.accent)
                        .cornerRadius(size * 0.15)
                        .offset(x: size * 0.45, y: size * -0.45)
                }
            }
            .onAppear {
                let imageManager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.deliveryMode = .highQualityFormat
                let targerSize = CGSize(width: 1024, height: 1024)
                
                imageManager.requestImage(for: asset, targetSize: CGSize(width: targerSize.width, height: targerSize.height), contentMode: .aspectFill, options: options) { (img, info) in
                    if let img = img {
                        withAnimation(.bouncy) { image = img }
                    }
                }
            }
    }
}
