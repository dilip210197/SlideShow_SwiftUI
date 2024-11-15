//
//  DataModel.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/19/24.
//

import SwiftUI
import Photos

class PhotoLibraryViewModel: ObservableObject {
    static let shared = PhotoLibraryViewModel()
    @Published var images: [PHAsset] = []
    
    init() {
        fetchPhotos()
    }
    
    func fetchPhotos() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .authorized {
            loadPhotos()
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    self.loadPhotos()
                }
            }
        }
    }
    
    private func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        fetchResult.enumerateObjects { (asset, index, stop) in
            DispatchQueue.main.async {
                self.images.append(asset)
            }
        }
    }
}
