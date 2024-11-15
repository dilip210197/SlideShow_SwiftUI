//
//  RenderSettings.swift
//  SlideShow
//
//  Created by Anuj Joshi on 24/07/24.
//

import Foundation
import AVFoundation
import UIKit
import Photos

public struct RenderSettings {
    public var size : CGSize = .zero
    public var fps: Int32 = 60   // frames per second
    public var avCodecKey: AVVideoCodecType = AVVideoCodecType.h264
    public var videoFilename: String = "render"
    public var videoFilenameExt: String = "mp4"
    public var saveToLibrary: Bool = true
    public var imageloop: Int = 1
    public var ratio: AspectRatio
    public var videoArray: [Data]
    public enum AspectRatio: String, CaseIterable, Identifiable {
        case standard = "Standard (4:3)"
        case portrait = "Portrait (9:16)"
        case square = "Square (1:1)"
        case landscape = "Landscape (16:9)"
        
        public var id: String { self.rawValue }
        
        var size: CGSize {
            switch self {
            case .standard:
                return CGSize(width: 4, height: 3)
            case .portrait:
                return CGSize(width: 9, height: 16)
            case .square:
                return CGSize(width: 1, height: 1)
            case .landscape:
                return CGSize(width: 16, height: 9)
            }
        }
    }
    public var outputURL: URL {
        let fileManager = FileManager.default
        if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            return tmpDirURL.appendingPathComponent(videoFilename).appendingPathExtension(videoFilenameExt)
        }
        fatalError("URLForDirectory() failed")
    }
    
    mutating func saveVideoURL(url: URL) {
        do {
            let videoData = try Data(contentsOf: url)
            try videoData.write(to: outputURL)
            self.videoArray.append(videoData)
            print("Video saved to: \(outputURL)")
        }
        catch {
            print("Error saving video: \(error)")
        }
    }
    mutating func removeAllFrameVideos() {
        self.videoArray.removeAll()
    }
    public init(size: CGSize = .zero, fps: Int32 = 6, avCodecKey: AVVideoCodecType = .h264, videoFilename: String = "render", videoFilenameExt: String = "mp4", saveToLibrary: Bool = true, imageloop: Int = 1, aspectRatio: AspectRatio = .standard) {
        self.size = size
        self.fps = fps
        self.avCodecKey = avCodecKey
        self.videoFilename = videoFilename
        self.videoFilenameExt = videoFilenameExt
        self.saveToLibrary = saveToLibrary
        self.imageloop = imageloop
        self.ratio = aspectRatio
        self.videoArray = []
    }
    
}
