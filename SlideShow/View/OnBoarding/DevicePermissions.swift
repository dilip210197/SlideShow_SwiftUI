//
//  PhotoLibraryPermission.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/8/24.
//

import Photos

@MainActor
class DevicePermissions: ObservableObject {
    
    @Published var isShowingAlert = false
    @Published var isGalleryPermissionGranted = false
    @Published var isCameraPermissionGranted = false
    
    // Ask for the permission for photo library access
    func requestGalleryPermission() async {
        if isGalleryPermissionGranted { return }
        
        PHPhotoLibrary.requestAuthorization { [self] status in
            DispatchQueue.main.async {
                switch status { 
                case .authorized:
                    self.isGalleryPermissionGranted = true
                case .denied:
                    self.isGalleryPermissionGranted = false
                    self.isShowingAlert = true
                default:
                    self.isGalleryPermissionGranted = false
                    self.isShowingAlert = true
                }
            }
        }
    }
     
    func requestCameraPermission() async {
        DispatchQueue.main.async { [self] in
            let videoStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if videoStatus == .authorized {
                // If Permission granted, configure the camera.
                isCameraPermissionGranted = true
            } else if videoStatus == .notDetermined {
                // In case the user has not been asked to grant access we request permission
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { _ in })
            } else if videoStatus == .denied {
                // If Permission denied, show a setting alert.
                isCameraPermissionGranted = false
                isShowingAlert = true
            }
        }
      }
}
