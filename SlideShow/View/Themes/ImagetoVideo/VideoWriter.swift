//
//  VideoWriter.swift
//  SlideShow
//
//  Created by Anuj Joshi on 24/07/24.
//

import Foundation
import AVFoundation
import UIKit
import CoreVideo
import CoreGraphics

public enum AnimationType:String,CaseIterable {
    case fadeInOut
    case shake // correct
    case swipeIn // need to out the frame .hold 1 sec in center
    case slowZoom
    case zoomInOut // correct
    case flip
    case bounce
    case slideAndFade
    case circularReveal
    
}

public class VideoWriter {
    
    let renderSettings: RenderSettings
    var gifFrames: [UIImage] = []
    var currentGifFrameIndex = 0
    var gifFrontFrames: [UIImage] = []
    var audioURL: URL?
    var animationChoosen:AnimationType = .fadeInOut
    
    public var videoWriter: AVAssetWriter!
    public var videoWriterInput: AVAssetWriterInput!
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    
    var isReadyForData: Bool {
        return videoWriterInput?.isReadyForMoreMediaData ?? false
    }
   
    class func pixelBufferFromImage(image: UIImage, gifFrames: [UIImage], currentGifFrameIndex: inout Int, gifFrontFrames: [UIImage], pixelBufferPool: CVPixelBufferPool, size: CGSize, frameNum: Int, totalFrames: Int, durationFrames: Int, aspectRatio: RenderSettings.AspectRatio, animationIndex: Int, selectedAnimation:AnimationType) -> CVPixelBuffer {
           var pixelBufferOut: CVPixelBuffer?
           let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBufferOut)
           if status != kCVReturnSuccess {
               fatalError("CVPixelBufferPoolCreatePixelBuffer() failed")
           }
           let pixelBuffer = pixelBufferOut!
           CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
           let data = CVPixelBufferGetBaseAddress(pixelBuffer)
           let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
           let context = CGContext(data: data, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)

           context!.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))

           // Draw the current GIF frame in the background
           if !gifFrames.isEmpty {
               let gifFrame = gifFrames[currentGifFrameIndex]
               currentGifFrameIndex = (currentGifFrameIndex + 1) % gifFrames.count
               let gifRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
               context?.draw(gifFrame.cgImage!, in: gifRect)
           }

           // Calculate the aspect ratio and size for drawing the image
           let imageAspectRatio = image.size.width / image.size.height
           var targetAspectRatio: CGFloat = 1.0
           switch aspectRatio {
           case .square:
               UserDefaults.standard.set("square", forKey: "aspectRatio")
               targetAspectRatio = 1.0
           case .landscape:
               UserDefaults.standard.set("landscape", forKey: "aspectRatio")
               targetAspectRatio = 16.0 / 9.0
           case .portrait:
               UserDefaults.standard.set("portrait", forKey: "aspectRatio")
               targetAspectRatio = 9.0 / 16.0
           case .standard:
               UserDefaults.standard.set("standard", forKey: "aspectRatio")
               targetAspectRatio = 4.0 / 3.0
//           default:
//               targetAspectRatio = imageAspectRatio
           }

           var drawSize = CGSize.zero
           if imageAspectRatio > targetAspectRatio {
               drawSize.width = min(size.width, image.size.width)
               drawSize.height = drawSize.width / imageAspectRatio
           } else {
               drawSize.height = min(size.height, image.size.height)
               drawSize.width = drawSize.height * imageAspectRatio
           }

           // Define animation parameters
           let enterDuration = durationFrames / 4
           let pauseDuration = durationFrames / 2
           let exitDuration = durationFrames / 4
           let vibrationAmplitude: CGFloat = 5.0 // Vibration amplitude in pixels
           let rotationAmplitude: CGFloat = 10.0 * .pi / 180.0 // 10 degrees in radians

           var x: CGFloat = 0
           var y: CGFloat = 0
           var imageRect = CGRect(x: 0, y: 0, width: drawSize.width, height: drawSize.height)

           switch selectedAnimation{
           case .fadeInOut:
               let animations = [
                   (enter: CGPoint(x: -drawSize.width, y: -drawSize.height), exit: CGPoint(x: size.width, y: size.height)), // Top-left to bottom-right
                   (enter: CGPoint(x: size.width, y: -drawSize.height), exit: CGPoint(x: -drawSize.width, y: size.height)), // Top-right to bottom-left
                   (enter: CGPoint(x: -drawSize.width, y: size.height), exit: CGPoint(x: size.width, y: -drawSize.height)), // Bottom-left to top-right
                   (enter: CGPoint(x: size.width, y: size.height), exit: CGPoint(x: -drawSize.width, y: -drawSize.height)), // Bottom-right to top-left
                   (enter: CGPoint(x: -drawSize.width, y: size.height / 2 - drawSize.height / 2), exit: CGPoint(x: size.width, y: size.height / 2 - drawSize.height / 2)), // Left to right
                   (enter: CGPoint(x: size.width / 2 - drawSize.width / 2, y: -drawSize.height), exit: CGPoint(x: size.width / 2 - drawSize.width / 2, y: size.height))  // Top to bottom
               ]

               let currentAnimation = animations[animationIndex % animations.count]

               if frameNum < enterDuration {
                   // Enter animation: from outside frame to center
                   let progress = CGFloat(frameNum) / CGFloat(enterDuration)
                   x = currentAnimation.enter.x + (size.width / 2 - drawSize.width / 2 - currentAnimation.enter.x) * progress
                   y = currentAnimation.enter.y + (size.height / 2 - drawSize.height / 2 - currentAnimation.enter.y) * progress
                   imageRect = CGRect(x: x, y: y, width: drawSize.width, height: drawSize.height)
               } else if frameNum < enterDuration + pauseDuration {
                   // Pause animation: stay at center with vibration
                   let pauseProgress = CGFloat(frameNum - enterDuration) / CGFloat(pauseDuration * 2)
                   x = size.width / 2 - drawSize.width / 2 //+ vibrationX
                   y = size.height / 2 - drawSize.height / 2 //+ vibrationY
                   imageRect = CGRect(x: x, y: y, width: drawSize.width, height: drawSize.height)
                   
               } else {
                   // Exit animation: from center to outside frame
                   let progress = CGFloat(frameNum - enterDuration - pauseDuration) / CGFloat(exitDuration)
                   x = size.width / 2 - drawSize.width / 2 + (currentAnimation.exit.x - (size.width / 2 - drawSize.width / 2)) * progress
                   y = size.height / 2 - drawSize.height / 2 + (currentAnimation.exit.y - (size.height / 2 - drawSize.height / 2)) * progress
                   imageRect = CGRect(x: x, y: y, width: drawSize.width, height: drawSize.height)
               }
           case .shake:
                  let shakeIntensity: CGFloat = 4.0
   //               let scaleIntensity: CGFloat = 0.05
                  let shakeDuration = durationFrames / 2
                  let shakeProgress = min(CGFloat(frameNum) / CGFloat(shakeDuration), 1.0)
                  let shakeOffset = shakeIntensity * sin(shakeProgress * 2.0 * .pi)
   //               let scale = 0.7 + scaleIntensity * sin(shakeProgress * 2.0 * .pi) // Slight scaling effect
               
                  let scaleImageSize = 1.1
               
                  x = size.width / 2 - (drawSize.width * scaleImageSize) / 2 + shakeOffset
                  y = size.height / 2 - (drawSize.height * scaleImageSize) / 2 + shakeOffset
               imageRect = CGRect(x: x, y: y, width: drawSize.width * scaleImageSize, height: drawSize.height * scaleImageSize)

               case .swipeIn:
               
                   let scaleImageSize = 1.4

                   let swipeDuration = durationFrames/2 // Make the entire duration dedicated to the swipe
                   let swipeProgress = min(CGFloat(frameNum) / CGFloat(swipeDuration), 1.0)
                   // Calculate x to stop at the center
                   x = -(drawSize.width * scaleImageSize) + swipeProgress * (size.width / 2 + (drawSize.width * scaleImageSize) / 2)
                   y = size.height / 2 - (drawSize.height * scaleImageSize ) / 2
               

               
                   imageRect = CGRect(x: x, y: y, width: drawSize.width * scaleImageSize, height: drawSize.height * scaleImageSize)
               
              case .slowZoom:
                  let zoomDuration = durationFrames / 2
                  let zoomProgress = min(CGFloat(frameNum) / CGFloat(zoomDuration), 1.0)
                  let scale = 1.0 + 0.2 * zoomProgress // Zoom in by 20%
               
                  let commonScaled = 1.2
               
                  let scaledWidth = drawSize.width * scale * commonScaled
                  let scaledHeight = drawSize.height * scale * commonScaled
                  x = size.width / 2 - scaledWidth / 2
                  y = size.height / 2 - scaledHeight / 2
               
                  imageRect = CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
               
           case .zoomInOut:
//               let zoomDuration = durationFrames
//               let zoomProgress = min(CGFloat(frameNum) / CGFloat(zoomDuration), 1.0)
//
//               // Oscillate between zooming in and out using a sine wave function
//               let scale = 1.0 + 0.2 * sin(zoomProgress * 2 * .pi) // Scale oscillates between 0.8 and 1.2
//
//               let scaledWidth = drawSize.width * scale
//               let scaledHeight = drawSize.height * scale
//
//               x = size.width / 2 - scaledWidth / 2
//               y = size.height / 2 - scaledHeight / 2
//
//               imageRect = CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
               let zoomDuration = durationFrames
               let zoomProgress = min(CGFloat(frameNum) / CGFloat(zoomDuration), 1.0)
               
               // Oscillate between zooming in and out using a sine wave function
               let scale = 1.0 + 0.2 * sin(zoomProgress * 2 * .pi) // Scale oscillates between 0.8 and 1.2
               
               // Add a slight rotation oscillation in sync with the zooming effect
               let rotationAngle = 0.05 * sin(zoomProgress * 4 * .pi) // Wobbles between -0.05 and 0.05 radians (about 3 degrees)
               
               // Calculate scaled dimensions
               let scaledWidth = drawSize.width * scale
               let scaledHeight = drawSize.height * scale
               
               // Position the image in the center
               x = size.width / 2 - scaledWidth / 2
               y = size.height / 2 - scaledHeight / 2
               
               // Apply rotation and translation to the context
               context?.saveGState()
               context?.translateBy(x: size.width / 2, y: size.height / 2) // Translate to center
               context?.rotate(by: rotationAngle) // Apply rotation
               context?.translateBy(x: -size.width / 2, y: -size.height / 2) // Translate back
               
               // Draw the image with scaling and rotation
               imageRect = CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
               
           case .flip:
               let flipDuration = durationFrames / 2
               let flipProgress = min(CGFloat(frameNum) / CGFloat(flipDuration), 1.0)
               let scaleX: CGFloat = frameNum < flipDuration ? (1.0 - flipProgress) : (flipProgress - 1.0)
               let scaleY: CGFloat = 1.0
               let flippedWidth = drawSize.width * abs(scaleX)
               let flippedHeight = drawSize.height * scaleY

               x = size.width / 2 - flippedWidth / 2
               y = size.height / 2 - flippedHeight / 2

               imageRect = CGRect(x: x, y: y, width: flippedWidth, height: flippedHeight)
               context?.translateBy(x: imageRect.midX, y: imageRect.midY)
               context?.scaleBy(x: scaleX, y: scaleY)
               context?.translateBy(x: -imageRect.midX, y: -imageRect.midY)
               
           case .bounce:
               let bounceDuration = durationFrames / 3
               let bounceProgress = min(CGFloat(frameNum) / CGFloat(bounceDuration), 1.0)
               let bounceScale = 1.0 + 0.1 * sin(bounceProgress * 2 * .pi)

               let scaledWidth = drawSize.width * bounceScale
               let scaledHeight = drawSize.height * bounceScale

               x = size.width / 2 - scaledWidth / 2
               y = size.height / 2 - scaledHeight / 2

               imageRect = CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
               
           case .slideAndFade:
               let slideInDuration = durationFrames / 4
                  let pauseDuration = durationFrames / 2
                  let slideOutDuration = durationFrames / 4
                  
                  if frameNum < slideInDuration {
                      // Slide in from right to center
                      let slideInProgress = CGFloat(frameNum / 2 ) / CGFloat(slideInDuration)
                      let slideInOffset = size.width * (1.0 - slideInProgress)
                      x = slideInOffset
                      y = size.height / 2 - drawSize.height / 2
                      let alpha = slideInProgress // Alpha increases as it slides in
                      context?.setAlpha(alpha)
                      
                  } else if frameNum < slideInDuration + pauseDuration {
                      // Pause at the center
                      x = size.width / 2 - drawSize.width / 2
                      y = size.height / 2 - drawSize.height / 2
                      context?.setAlpha(1.0) // Full opacity during the pause
                      
                  } else {
                      // Slide out to the left
                      let slideOutProgress = CGFloat(frameNum - slideInDuration - pauseDuration) / CGFloat(slideOutDuration)
                      let slideOutOffset = (size.width / 2 - drawSize.width / 2) * (1.0 - slideOutProgress)
                      x = slideOutOffset - drawSize.width // Slide out to the left
                      y = size.height / 2 - drawSize.height / 2
                      let alpha = 1.0 - slideOutProgress // Fade out as it slides out
                      context?.setAlpha(alpha)
                  }
                  
                  imageRect = CGRect(x: x, y: y, width: drawSize.width, height: drawSize.height)
               
           case .circularReveal:
               let revealProgress = min(CGFloat(frameNum) / CGFloat(durationFrames), 1.0)
               let radius = max(size.width, size.height) * revealProgress

               let clipPath = CGPath(ellipseIn: CGRect(x: size.width / 2 - radius, y: size.height / 2 - radius, width: radius * 2, height: radius * 2), transform: nil)
               context?.addPath(clipPath)
               context?.clip()

               x = size.width / 2 - drawSize.width / 2
               y = size.height / 2 - drawSize.height / 2
               imageRect = CGRect(x: x, y: y, width: drawSize.width, height: drawSize.height)
           }
          
          context?.interpolationQuality = .high

           context?.draw(image.cgImage!, in: imageRect)

           // Draw the border
           context?.setStrokeColor(UIColor.white.cgColor)
           context?.setLineWidth(10.0) // Adjust the border width as needed
           context?.stroke(imageRect)
           context?.saveGState()
           
           // Draw the foreground GIF frame, if available
           if !gifFrontFrames.isEmpty {
               let gifFrame = gifFrontFrames[currentGifFrameIndex]
               currentGifFrameIndex = (currentGifFrameIndex + 1) % gifFrontFrames.count
               let gifRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
               context?.draw(gifFrame.cgImage!, in: gifRect)
           }
           
           CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
           
           return pixelBuffer
       }
    class private func randomCorner(size: CGSize, drawSize: CGSize) -> CGPoint {
        let corners = [
            CGPoint(x: 0, y: 0), // top-left
            CGPoint(x: size.width - drawSize.width, y: 0), // top-right
            CGPoint(x: 0, y: size.height - drawSize.height), // bottom-left
            CGPoint(x: size.width - drawSize.width, y: size.height - drawSize.height) // bottom-right
        ]
        return corners.randomElement()!
    }
    public init(renderSettings: RenderSettings, gifFrames: [UIImage], gifFrontFrames: [UIImage], audioURL: URL,animation:AnimationType) {
        self.renderSettings = renderSettings
        self.gifFrames = gifFrames
        self.gifFrontFrames = gifFrontFrames
        self.audioURL = audioURL
        self.animationChoosen = animation
    }
    
    public func start() {
        
        let avOutputSettings: [String: Any] = [
            AVVideoCodecKey: renderSettings.avCodecKey,
            AVVideoWidthKey: NSNumber(value: Float(renderSettings.size.width)),
            AVVideoHeightKey: NSNumber(value: Float(renderSettings.size.height))
        ]
        
        func createPixelBufferAdaptor() {
            let sourcePixelBufferAttributesDictionary = [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: NSNumber(value: Float(renderSettings.size.width)),
                kCVPixelBufferHeightKey as String: NSNumber(value: Float(renderSettings.size.height))
            ]
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput,
                                                                      sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        }
        
        func createAssetWriter(outputURL: URL) -> AVAssetWriter {
            guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4) else {
                fatalError("AVAssetWriter() failed")
            }
            
            guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaType.video) else {
                fatalError("canApplyOutputSettings() failed")
            }
            
            return assetWriter
        }
        
        videoWriter = createAssetWriter(outputURL: renderSettings.outputURL)
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
        
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        }
        else {
            fatalError("canAddInput() returned false")
        }
        
        // The pixel buffer adaptor must be created before we start writing.
        createPixelBufferAdaptor()
        
        if videoWriter.startWriting() == false {
            fatalError("startWriting() failed")
        }
        
        videoWriter.startSession(atSourceTime: CMTime.zero)
        
        precondition(pixelBufferAdaptor.pixelBufferPool != nil, "nil pixelBufferPool")
    }
    
    public func render(appendPixelBuffers: ((VideoWriter)->Bool)?, completion: (()->Void)?) {
        
        precondition(videoWriter != nil, "Call start() to initialze the writer")
        
        let queue = DispatchQueue(label: "mediaInputQueue")
        videoWriterInput.requestMediaDataWhenReady(on: queue) {
            let isFinished = appendPixelBuffers?(self) ?? false
            if isFinished {
                self.videoWriterInput.markAsFinished()
                self.videoWriter.finishWriting() {
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
            }
            else {
                // Fall through. The closure will be called again when the writer is ready.
            }
        }
    }
    
    public func getFrameBuffer(image: UIImage, frameNum: Int, totalFrames: Int, durationFrames: Int, animationIndex: Int) -> CVPixelBuffer {
        return VideoWriter.pixelBufferFromImage(image: image, gifFrames: gifFrames, currentGifFrameIndex: &currentGifFrameIndex, gifFrontFrames: gifFrontFrames, pixelBufferPool: pixelBufferAdaptor.pixelBufferPool!, size: renderSettings.size, frameNum: frameNum, totalFrames: totalFrames, durationFrames: durationFrames, aspectRatio: renderSettings.ratio, animationIndex: animationIndex, selectedAnimation: animationChoosen)

    }
    
    public func addBuffer(pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime) -> Bool {
        precondition(pixelBufferAdaptor != nil, "Call start() to initialze the writer")
        return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }
    
//    public func addImage(image: UIImage, withPresentationTime presentationTime: CMTime, frameNum: Int, totalFrames: Int, durationFrames: Int) -> Bool {
//        precondition(pixelBufferAdaptor != nil, "Call start() to initialze the writer")
//        
//        let pixelBuffer = VideoWriter.pixelBufferFromImage(image: image, gifFrames: gifFrames, currentGifFrameIndex: &currentGifFrameIndex, gifFrontFrames: gifFrontFrames, pixelBufferPool: pixelBufferAdaptor.pixelBufferPool!, size: renderSettings.size, frameNum: frameNum, totalFrames: totalFrames, durationFrames: durationFrames, aspectRatio: renderSettings.ratio, animationIndex: animationIndex)
//        return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
//    }
}
