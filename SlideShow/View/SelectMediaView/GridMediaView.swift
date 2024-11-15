//
//  GridItemView.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/19/24.
//

import SwiftUI
import Photos

struct GridMediaView: View {
    let size: Double
    let asset: PHAsset
    let idx: Int
    @State var image: UIImage?
    @Binding var selectedIdx: [Int]
    
    var body: some View {
        Image(uiImage: image ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size, alignment: .center)
            .clipped()
            .cornerRadius(5)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(.accent, style: StrokeStyle(lineWidth: 2))
                    //.border(.accent, width: 2)
                    .opacity(isImageSelected() ? 1 : 0)
                    .background(.clear)
            }
            .onAppear {
                let imageManager = PHImageManager.default()
                let options = PHImageRequestOptions()
                options.isSynchronous = false
                options.deliveryMode = .highQualityFormat
                options.resizeMode = .exact
                options.isNetworkAccessAllowed = true  // Allow fetching from iCloud if necessary
                let targetsize = CGSize(width: 1024, height: 1024)
                imageManager.requestImage(for: asset, targetSize: CGSize(width: targetsize.width, height: targetsize.height), contentMode: .aspectFill, options: options) { (img, info) in
                    if let img = img {
                        withAnimation(.bouncy) { image = img }
                    }
                }
            }
    }
    
    func isImageSelected() -> Bool {
        return selectedIdx.contains(idx)
    }
}
