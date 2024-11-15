//
//  ImageAnimator.swift
//  SlideShow
//
//  Created by Anuj Joshi on 24/07/24.
//

import Foundation
import UIKit
import Photos

public class ImageAnimator {
    
    // Apple suggests a timescale of 600 because it's a multiple of standard video rates 24, 25, 30, 60 fps etc.
    static let kTimescale: Int32 = 600
    
    public let settings: RenderSettings
    public let videoWriter: VideoWriter
    public var images: [UIImage]!
    public var gifFrames: [UIImage]!
    public var gifFrontFrames: [UIImage]!
    public var audioURL: URL?
    var themeviewModel = ThemeViewModel.shared
    var frameNum = 0
    
    public class func saveToLibrary(videoURL: URL) {
        
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                if !success {
                    print("Could not save video to photo library: \(String(describing: error))")
                }
            }
        }
    }
    
    public class func removeFileAtURL(fileURL: URL) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        }
        catch {
                
        }
    }

    public init(renderSettings: RenderSettings, gifFrames: [UIImage], gifFrontFrames: [UIImage], audioURL: URL, animation:AnimationType) {
        settings = renderSettings
        videoWriter = VideoWriter(renderSettings: settings, gifFrames: gifFrames, gifFrontFrames: gifFrontFrames, audioURL: audioURL, animation: animation)
    }

    public func render(completion: (()->Void)?) {

        // The VideoWriter will fail if a file exists at the URL, so clear it out first.
        ImageAnimator.removeFileAtURL(fileURL: settings.outputURL)

        videoWriter.start()
        videoWriter.render(appendPixelBuffers: appendPixelBuffers) { [weak self] in
            guard let self = self else {return}
            if self.settings.saveToLibrary {
                ImageAnimator.saveToLibrary(videoURL: self.settings.outputURL)
            }
            completion?()
        }
    }

    // This is the callback function for VideoWriter.render()
    func appendPixelBuffers(writer: VideoWriter) -> Bool {
        let frameDuration = CMTimeMake(value: Int64(ImageAnimator.kTimescale / settings.fps), timescale: ImageAnimator.kTimescale)
        var pixelBuffer: CVPixelBuffer!
        let totalFrames = images.count * settings.imageloop
        let framesPerImage = settings.imageloop // Number of frames per image

        while !images.isEmpty {
            if writer.isReadyForData == false {
                return false
            }

            let imageIndex = frameNum / framesPerImage
            let frameInImage = frameNum % framesPerImage

            if frameInImage == 0 || pixelBuffer == nil {
                let image = images.first
                pixelBuffer = writer.getFrameBuffer(image: image!, frameNum: frameInImage, totalFrames: totalFrames, durationFrames: framesPerImage, animationIndex: imageIndex)
            }

            let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameNum))
            let success = writer.addBuffer(pixelBuffer: pixelBuffer, withPresentationTime: presentationTime)
            if success == false {
                print("failed to add image")
            } else {
                if frameInImage == framesPerImage - 1 {
                    images.removeFirst()
                }
                frameNum += 1
            }
        }
        return true
    }
}
