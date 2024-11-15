//
//  ThemeViewModel.swift
//  SlideShow
//
//  Created by Anuj Joshi on 14/06/24.
//

import Foundation
import UIKit
import AVFoundation
import PhotosUI
import AVKit
import ImageIO
import Combine

class ThemeViewModel: ObservableObject {
    
    public static let shared = ThemeViewModel()
    private var exportSession: AVAssetExportSession?
    private let exportQueue = ExportSessionQueue.shared
    private var layercomposition = AVMutableVideoComposition()
    private var selectedItem =  String()
    private var animationStore = AnimationStore.shared
    @Published var themeURL: URL?
    private var asset: AVAsset?
    @Published var isLoading: Bool = false
    private var exportResult: Result<URL, Error>?
    private var animtionTop = CAKeyframeAnimation()
    private var animationBack = CAKeyframeAnimation()
    private var viewmodelAV = MediaPlayer.shared
    private var gifImages: [UIImage]?    
    private var gifFrontImages: [UIImage]?
    private var audioURL: URL?
    private var animationSet:AnimationType = .fadeInOut
    public var audioFileURL: URL?
    
//    private var sequencer: NWImageSequencer? = NWImageSequencer()
    private var path:String?

    var imageAnimator: ImageAnimator?
    var setting = RenderSettings()
    let maxDimension: CGFloat = 1600 // Maximum dimension for video size scaling
    
    @Published var selectedAspectRatio: RenderSettings.AspectRatio = .portrait {
        didSet {
            updateVideoSize()
        }
    }
    @Published var exportProgress: Float = 0.0
    @Published var exportStatus: String = ""
    private var cancellables = Set<AnyCancellable>()
    @Published var selectedImage: [UIImage] = []
    
    private func updateVideoSize() {
        let maxDimension: CGFloat = 1600 // Maximum dimension for video size scaling
        var aspectRatio = selectedAspectRatio.size.width / selectedAspectRatio.size.height
        if let aspectRatioValue = UserDefaults.standard.string(forKey: "aspectRatio") {
            if aspectRatioValue == "standard" {
                aspectRatio = 4/3
            }else if aspectRatioValue == "portrait" {
                aspectRatio = 6/16
            }else if aspectRatioValue == "landscape" {
                aspectRatio = 16/9
            }else if aspectRatioValue == "square" {
                aspectRatio = 1/1
            }else{
                aspectRatio = 6/16
            }
        }else{
            aspectRatio = selectedAspectRatio.size.width / selectedAspectRatio.size.height
        }
        if aspectRatio > 1 { // Landscape
            setting.size = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else { // Portrait or Square
            setting.size = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
    }

    func removeItemIfExisted(_ url:URL) -> Void {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            }
            catch {
                print("Failed to delete file")
            }
        }
    }
    
    func setupImages(selectedImages: [UIImage], ratio: Ratio) {
        if ratio.rawValue == 0 {
            selectedAspectRatio = .standard
        }else if ratio.rawValue == 1 {
            selectedAspectRatio = .portrait
        }else if ratio.rawValue == 2 {
            selectedAspectRatio = .landscape
        }else if ratio.rawValue == 3 {
            selectedAspectRatio = .square
        }
        let aspectRatio = selectedAspectRatio.size.width / selectedAspectRatio.size.height
        if aspectRatio > 1 { // Landscape
            setting.size = CGSize(width: maxDimension / 2, height: (maxDimension / 2) / aspectRatio)
        } else { // Portrait or Square
            setting.size = CGSize(width: (maxDimension / 2) * aspectRatio, height: maxDimension / 2)
        }
        
        // Resize each image based on the calculated size
            let resizedImages = selectedImages.map { image -> UIImage in
                return resizeImage(image: image, targetSize: setting.size)
            }
        self.selectedImage = resizedImages
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let halfSize = CGSize(width: targetSize.width / 2, height: targetSize.height / 2)
        let size = image.size

        let widthRatio  = halfSize.width  / size.width
        let heightRatio = halfSize.height / size.height
        let scaleFactor = max(widthRatio, heightRatio) // Scale to fill

        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: halfSize)
        let scaledImage = renderer.image { context in
            let origin = CGPoint(x: (halfSize.width - scaledImageSize.width) / 2, y: (halfSize.height - scaledImageSize.height) / 2)
            image.draw(in: CGRect(origin: origin, size: scaledImageSize))
        }
        
        return scaledImage
    }

    func extractFrames(from gifData: Data) -> [UIImage]? {
        guard let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            return nil
        }

        let frameCount = CGImageSourceGetCount(source)
        var frames: [UIImage] = []

        for index in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                let frame = UIImage(cgImage: cgImage)
                frames.append(frame)
            }
        }

        return frames
    }
    
    public func setupVideo(viewModel: MediaPlayer, selectedTheme: String?, selectedImages: [UIImage]?, animation:AnimationType, frameDuration:Double) {
        autoreleasepool {
            
            self.viewmodelAV = viewModel
            if selectedTheme == "" {
                self.selectedItem = "Love"
                
            }else {
                self.selectedItem = selectedTheme ?? "Love"
            }
            UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
            audioFileURL = UserDefaults.standard.url(forKey: "\(selectedTheme ?? "Love")AudioURL")
            
            if let cleanedURLString = cleanUpURL(audioFileURL?.absoluteString ?? "") {
                audioFileURL = URL(string: cleanedURLString)
            }
            if self.selectedItem == "Love" {
                self.animationSet = .fadeInOut
                if audioFileURL == nil {
                    self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Beautiful.mp3")
                }else{
                    self.audioURL = audioFileURL
                }
                //self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Beautiful.mp3")
                if self.selectedAspectRatio == .square{
                    if let path = Bundle.main.path(forResource: "Love-back_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Love-front_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .standard {
                    if let path = Bundle.main.path(forResource: "Love-back_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Love-front_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .landscape {
                    if let path = Bundle.main.path(forResource: "Love-back_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Love-front_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .portrait {
                    if let path = Bundle.main.path(forResource: "Love-back_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Love-front_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }
            } else if self.selectedItem == "Anniversary" {
                self.animationSet = .bounce
                //self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Love Is.mp3")
                if audioFileURL == nil {
                    self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Love Is.mp3")
                }else{
                    self.audioURL = audioFileURL
                }
                if self.selectedAspectRatio == .square {
                    if let path = Bundle.main.path(forResource: "Anniversary-back_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Anniversary-front_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .landscape {
                    if let path = Bundle.main.path(forResource: "Anniversary-back_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Anniversary-front_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .portrait {
                    if let path = Bundle.main.path(forResource: "Anniversary-back_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Anniversary-front_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .standard {
                    if let path = Bundle.main.path(forResource: "Anniversary-back_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Anniversary-front_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }
            }else if self.selectedItem == "Birthday" {
                self.animationSet = .slideAndFade
                //self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Happy Birthday Rock.mp3")
                if audioFileURL == nil {
                    self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Happy Birthday Rock.mp3")
                }else{
                    self.audioURL = audioFileURL
                }
                if self.selectedAspectRatio == .square {
                    if let path = Bundle.main.path(forResource: "Birthday-back_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Birthday-front_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .landscape {
                    if let path = Bundle.main.path(forResource: "Birthday-back_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Birthday-front_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .portrait {
                    if let path = Bundle.main.path(forResource: "Birthday-back_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Birthday-front_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .standard {
                    if let path = Bundle.main.path(forResource: "Birthday-back_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Birthday-front_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }
            }else if self.selectedItem == "Celebration" {
                self.animationSet = .slowZoom
                //self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Electroslam.mp3")
                if audioFileURL == nil {
                    self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Electroslam.mp3")
                }else{
                    self.audioURL = audioFileURL
                }
                
                if self.selectedAspectRatio == .square {
                    if let path = Bundle.main.path(forResource: "Celebration-back_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Celebration-front_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .landscape {
                    if let path = Bundle.main.path(forResource: "Celebration-back_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Celebration-front_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .portrait {
                    if let path = Bundle.main.path(forResource: "Celebration-back_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Celebration-front_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .standard {
                    if let path = Bundle.main.path(forResource: "Celebration-back_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Celebration-front_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }
            }else if self.selectedItem == "Vintage" {
                self.animationSet = .zoomInOut
                //self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/I Get By With a LIttle Help.mp3")
                if audioFileURL == nil {
                    self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/I Get By With a LIttle Help.mp3")
                }else{
                    self.audioURL = audioFileURL
                }
                if self.selectedAspectRatio == .square {
                    if let path = Bundle.main.path(forResource: "Vintage-back_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Vintage-front_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .landscape {
                    if let path = Bundle.main.path(forResource: "Vintage-back_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Vintage-front_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .portrait {
                    if let path = Bundle.main.path(forResource: "Vintage-back_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Vintage-front_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .standard {
                    if let path = Bundle.main.path(forResource: "Vintage-back_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Vintage-front_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }
            }else if self.selectedItem == "Memories" {
                self.animationSet = .zoomInOut
                //self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Memories.mp3")
                if audioFileURL == nil {
                    self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Memories.mp3")
                }else{
                    self.audioURL = audioFileURL
                }
                if self.selectedAspectRatio == .square {
                    if let path = Bundle.main.path(forResource: "Memories-back_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Memories-front_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .landscape {
                    if let path = Bundle.main.path(forResource: "Memories-back_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Memories-front_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .portrait {
                    if let path = Bundle.main.path(forResource: "Memories-back_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Memories-front_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .standard {
                    if let path = Bundle.main.path(forResource: "Memories-back_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Memories-front_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }
            } else if self.selectedItem == "Christmas" {
                self.animationSet = .circularReveal
                //self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/White Snow.mp3")
                if audioFileURL == nil {
                    self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/White Snow.mp3")
                }else{
                    self.audioURL = audioFileURL
                }
                if self.selectedAspectRatio == .square {
                    if let path = Bundle.main.path(forResource: "Christmas-back_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Christmas-front_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .landscape {
                    if let path = Bundle.main.path(forResource: "Christmas-back_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Christmas-front_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .portrait {
                    if let path = Bundle.main.path(forResource: "Christmas-back_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Christmas-front_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .standard {
                    if let path = Bundle.main.path(forResource: "Christmas-back_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Christmas-front_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }
            }else if self.selectedItem == "Calm" {
                self.animationSet = .zoomInOut
                //self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Lost In A Moment.mp3")
                if audioFileURL == nil {
                    self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Lost In A Moment.mp3")
                }else{
                    self.audioURL = audioFileURL
                }
                if self.selectedAspectRatio == .square {
                    if let path = Bundle.main.path(forResource: "Calm-back_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Calm-front_square", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .landscape {
                    if let path = Bundle.main.path(forResource: "Calm-back_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Calm-front_landscape", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .portrait {
                    if let path = Bundle.main.path(forResource: "Calm-back_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Calm-front_portrait", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }else if self.selectedAspectRatio == .standard {
                    if let path = Bundle.main.path(forResource: "Calm-back_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifImages?.removeAll()
                            self.gifImages = frames
                        }
                    }
                    if let path = Bundle.main.path(forResource: "Calm-front_standard", ofType: "gif") {
                        let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                        if let frames = self.extractFrames(from: gifData) {
                            // Use the frames array
                            print("Extracted \(frames.count) frames")
                            self.gifFrontImages?.removeAll()
                            self.gifFrontImages = frames
                        }
                    }
                }
            }
            /*audioFileURL = UserDefaults.standard.url(forKey: "audioURL")
             
             if let cleanedURLString = cleanUpURL(audioFileURL?.absoluteString ?? "") {
             audioFileURL = URL(string: cleanedURLString)
             }*/
            self.videoProcess(audioURL: audioURL!, frameDuration: frameDuration)
            /*if audioFileURL == nil {
             print("audioFileURL \(String(describing: audioFileURL))")
             UserDefaults.standard.set(audioURL, forKey: "audioURL")
             self.videoProcess(audioURL: audioURL!, frameDuration: frameDuration)
             }else{
             self.videoProcess(audioURL: audioFileURL!,frameDuration: frameDuration)
             }*/
        }
    }
    
    func loveThemeURL(viewModel: MediaPlayer, selectedTheme: String?, selectedImages: [UIImage]?, animation:AnimationType, frameDuration:Double) {
        
        self.viewmodelAV = viewModel
        if selectedTheme == "" {
            self.selectedItem = "Love"
            
        }else {
            self.selectedItem = selectedTheme ?? "Love"
        }
        UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
        audioFileURL = UserDefaults.standard.url(forKey: "\(selectedTheme ?? "Love")AudioURL")
        
        if let cleanedURLString = cleanUpURL(audioFileURL?.absoluteString ?? "") {
            audioFileURL = URL(string: cleanedURLString)
        }
        
        self.animationSet = .fadeInOut
        if audioFileURL == nil {
            self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Beautiful.mp3")
        }else{
            self.audioURL = audioFileURL
        }
        
        if self.selectedAspectRatio == .square{
            if let path = Bundle.main.path(forResource: "Love-back_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Love-front_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .standard {
            if let path = Bundle.main.path(forResource: "Love-back_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Love-front_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .landscape {
            if let path = Bundle.main.path(forResource: "Love-back_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Love-front_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .portrait {
            if let path = Bundle.main.path(forResource: "Love-back_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Love-front_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }
        
        setting.saveToLibrary = false
        setting.fps = 60
        setting.imageloop = Int(50 * frameDuration)
        setting.ratio = selectedAspectRatio
        if !selectedImage.isEmpty {
            imageAnimator = ImageAnimator(renderSettings: setting, gifFrames: gifImages!, gifFrontFrames: gifFrontImages!, audioURL: self.audioURL!, animation:animationSet)
            imageAnimator?.images = self.selectedImage
            print("render time begin")
            let start = Date().timeIntervalSince1970
            imageAnimator?.render {
                let end = Date().timeIntervalSince1970
                print("render time \(end - start)")
                print("render complete \(self.setting.outputURL)")
                self.isLoading = true
                self.themeURL = self.setting.outputURL
                self.setting.videoArray.removeAll()
                self.setting.saveVideoURL(url: self.setting.outputURL)
                print("self.setting.videoArray \(self.setting.videoArray)")
                self.viewmodelAV.stop()
                self.viewmodelAV.removePlayerObservers()
                UserDefaults.standard.set(self.setting.outputURL.absoluteString, forKey: "LoveVideoURL")
                self.anniversaryThemeURL(frameDuration: frameDuration)
                UserDefaults.standard.set(self.setting.outputURL, forKey: "videoURL")
            }
        }
    }
    
    func anniversaryThemeURL(frameDuration:Double) {
        self.animationSet = .bounce
        
        if audioFileURL == nil {
            self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Love Is.mp3")
        }else{
            self.audioURL = audioFileURL
        }
        if self.selectedAspectRatio == .square {
            if let path = Bundle.main.path(forResource: "Anniversary-back_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Anniversary-front_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .landscape {
            if let path = Bundle.main.path(forResource: "Anniversary-back_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Anniversary-front_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .portrait {
            if let path = Bundle.main.path(forResource: "Anniversary-back_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Anniversary-front_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .standard {
            if let path = Bundle.main.path(forResource: "Anniversary-back_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Anniversary-front_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }
        setting.saveToLibrary = false
        setting.fps = 60
        setting.imageloop = Int(50 * frameDuration)
        setting.ratio = selectedAspectRatio
        if !selectedImage.isEmpty {
            imageAnimator = ImageAnimator(renderSettings: setting, gifFrames: gifImages!, gifFrontFrames: gifFrontImages!, audioURL: self.audioURL!, animation:animationSet)
            imageAnimator?.images = self.selectedImage
            print("render time begin")
            let start = Date().timeIntervalSince1970
            imageAnimator?.render {
                let end = Date().timeIntervalSince1970
                print("render time \(end - start)")
                print("render complete \(self.setting.outputURL)")
                self.isLoading = true
                self.themeURL = self.setting.outputURL
                self.setting.saveVideoURL(url: self.setting.outputURL)
                print("self.setting.videoArray \(self.setting.videoArray)")
                self.viewmodelAV.stop()
                self.viewmodelAV.removePlayerObservers()
                UserDefaults.standard.set(self.setting.outputURL.absoluteString, forKey: "AnniversaryVideoURL")
                self.birthdayThemeURL(frameDuration: frameDuration)
                UserDefaults.standard.set(self.setting.outputURL, forKey: "videoURL")
            }
        }
    }
    
    func birthdayThemeURL(frameDuration:Double) {
        self.animationSet = .slideAndFade
        
        if audioFileURL == nil {
            self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Happy Birthday Rock.mp3")
        }else{
            self.audioURL = audioFileURL
        }
        if self.selectedAspectRatio == .square {
            if let path = Bundle.main.path(forResource: "Birthday-back_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Birthday-front_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .landscape {
            if let path = Bundle.main.path(forResource: "Birthday-back_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Birthday-front_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .portrait {
            if let path = Bundle.main.path(forResource: "Birthday-back_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Birthday-front_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .standard {
            if let path = Bundle.main.path(forResource: "Birthday-back_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Birthday-front_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }
        
        setting.saveToLibrary = false
        setting.fps = 60
        setting.imageloop = Int(50 * frameDuration)
        setting.ratio = selectedAspectRatio
        if !selectedImage.isEmpty {
            imageAnimator = ImageAnimator(renderSettings: setting, gifFrames: gifImages!, gifFrontFrames: gifFrontImages!, audioURL: self.audioURL!, animation:animationSet)
            imageAnimator?.images = self.selectedImage
            print("render time begin")
            let start = Date().timeIntervalSince1970
            imageAnimator?.render {
                let end = Date().timeIntervalSince1970
                print("render time \(end - start)")
                print("render complete \(self.setting.outputURL)")
                self.isLoading = true
                self.themeURL = self.setting.outputURL
                self.setting.saveVideoURL(url: self.setting.outputURL)
                self.viewmodelAV.stop()
                self.viewmodelAV.removePlayerObservers()
                UserDefaults.standard.set(self.setting.outputURL.absoluteString, forKey: "BirthdayVideoURL")
                self.celebrationThemeURL(frameDuration: frameDuration)
                UserDefaults.standard.set(self.setting.outputURL, forKey: "videoURL")
            }
        }
    }
    
    func celebrationThemeURL(frameDuration:Double) {
        self.animationSet = .slowZoom
        
        if audioFileURL == nil {
            self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Electroslam.mp3")
        }else{
            self.audioURL = audioFileURL
        }
        
        if self.selectedAspectRatio == .square {
            if let path = Bundle.main.path(forResource: "Celebration-back_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Celebration-front_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .landscape {
            if let path = Bundle.main.path(forResource: "Celebration-back_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Celebration-front_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .portrait {
            if let path = Bundle.main.path(forResource: "Celebration-back_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Celebration-front_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .standard {
            if let path = Bundle.main.path(forResource: "Celebration-back_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Celebration-front_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }
        
        setting.saveToLibrary = false
        setting.fps = 60
        setting.imageloop = Int(50 * frameDuration)
        setting.ratio = selectedAspectRatio
        if !selectedImage.isEmpty {
            imageAnimator = ImageAnimator(renderSettings: setting, gifFrames: gifImages!, gifFrontFrames: gifFrontImages!, audioURL: self.audioURL!, animation:animationSet)
            imageAnimator?.images = self.selectedImage
            print("render time begin")
            let start = Date().timeIntervalSince1970
            imageAnimator?.render {
                let end = Date().timeIntervalSince1970
                print("render time \(end - start)")
                print("render complete \(self.setting.outputURL)")
                self.isLoading = true
                self.themeURL = self.setting.outputURL
                self.setting.saveVideoURL(url: self.setting.outputURL)
                self.viewmodelAV.stop()
                self.viewmodelAV.removePlayerObservers()
                UserDefaults.standard.set(self.setting.outputURL.absoluteString, forKey: "CelebrationVideoURL")
                self.vintageThemeURL(frameDuration: frameDuration)
                UserDefaults.standard.set(self.setting.outputURL, forKey: "videoURL")
            }
        }
    }
    
    func vintageThemeURL(frameDuration:Double) {
        self.animationSet = .zoomInOut
        
        if audioFileURL == nil {
            self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/I Get By With a LIttle Help.mp3")
        }else{
            self.audioURL = audioFileURL
        }
        if self.selectedAspectRatio == .square {
            if let path = Bundle.main.path(forResource: "Vintage-back_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Vintage-front_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .landscape {
            if let path = Bundle.main.path(forResource: "Vintage-back_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Vintage-front_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .portrait {
            if let path = Bundle.main.path(forResource: "Vintage-back_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Vintage-front_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .standard {
            if let path = Bundle.main.path(forResource: "Vintage-back_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Vintage-front_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }
    
        
        setting.saveToLibrary = false
        setting.fps = 60
        setting.imageloop = Int(50 * frameDuration)
        setting.ratio = selectedAspectRatio
        if !selectedImage.isEmpty {
            imageAnimator = ImageAnimator(renderSettings: setting, gifFrames: gifImages!, gifFrontFrames: gifFrontImages!, audioURL: self.audioURL!, animation:animationSet)
            imageAnimator?.images = self.selectedImage
            print("render time begin")
            let start = Date().timeIntervalSince1970
            imageAnimator?.render {
                let end = Date().timeIntervalSince1970
                print("render time \(end - start)")
                print("render complete \(self.setting.outputURL)")
                self.isLoading = true
                self.themeURL = self.setting.outputURL
                self.setting.saveVideoURL(url: self.setting.outputURL)
                self.viewmodelAV.stop()
                self.viewmodelAV.removePlayerObservers()
                UserDefaults.standard.set(self.setting.outputURL.absoluteString, forKey: "VintageVideoURL")
                self.memoriesThemeURL(frameDuration: frameDuration)
                UserDefaults.standard.set(self.setting.outputURL, forKey: "videoURL")
            }
        }
    }
    
    func memoriesThemeURL(frameDuration:Double) {
        self.animationSet = .zoomInOut
        
        if audioFileURL == nil {
            self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Memories.mp3")
        }else{
            self.audioURL = audioFileURL
        }
        if self.selectedAspectRatio == .square {
            if let path = Bundle.main.path(forResource: "Memories-back_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Memories-front_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .landscape {
            if let path = Bundle.main.path(forResource: "Memories-back_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Memories-front_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .portrait {
            if let path = Bundle.main.path(forResource: "Memories-back_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Memories-front_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .standard {
            if let path = Bundle.main.path(forResource: "Memories-back_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Memories-front_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }
    
        
        setting.saveToLibrary = false
        setting.fps = 60
        setting.imageloop = Int(50 * frameDuration)
        setting.ratio = selectedAspectRatio
        if !selectedImage.isEmpty {
            imageAnimator = ImageAnimator(renderSettings: setting, gifFrames: gifImages!, gifFrontFrames: gifFrontImages!, audioURL: self.audioURL!, animation:animationSet)
            imageAnimator?.images = self.selectedImage
            print("render time begin")
            let start = Date().timeIntervalSince1970
            imageAnimator?.render {
                let end = Date().timeIntervalSince1970
                print("render time \(end - start)")
                print("render complete \(self.setting.outputURL)")
                self.isLoading = true
                self.themeURL = self.setting.outputURL
                self.setting.saveVideoURL(url: self.setting.outputURL)
                self.viewmodelAV.stop()
                self.viewmodelAV.removePlayerObservers()
                UserDefaults.standard.set(self.setting.outputURL.absoluteString, forKey: "MemoriesVideoURL")
                self.christmasThemeURL(frameDuration: frameDuration)
                UserDefaults.standard.set(self.setting.outputURL, forKey: "videoURL")
            }
        }
    }
    
    func christmasThemeURL(frameDuration:Double) {
        self.animationSet = .circularReveal
        
        if audioFileURL == nil {
            self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/White Snow.mp3")
        }else{
            self.audioURL = audioFileURL
        }
        if self.selectedAspectRatio == .square {
            if let path = Bundle.main.path(forResource: "Christmas-back_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Christmas-front_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .landscape {
            if let path = Bundle.main.path(forResource: "Christmas-back_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Christmas-front_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .portrait {
            if let path = Bundle.main.path(forResource: "Christmas-back_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Christmas-front_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .standard {
            if let path = Bundle.main.path(forResource: "Christmas-back_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Christmas-front_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }
    
        
        setting.saveToLibrary = false
        setting.fps = 60
        setting.imageloop = Int(50 * frameDuration)
        setting.ratio = selectedAspectRatio
        if !selectedImage.isEmpty {
            imageAnimator = ImageAnimator(renderSettings: setting, gifFrames: gifImages!, gifFrontFrames: gifFrontImages!, audioURL: self.audioURL!, animation:animationSet)
            imageAnimator?.images = self.selectedImage
            print("render time begin")
            let start = Date().timeIntervalSince1970
            imageAnimator?.render {
                let end = Date().timeIntervalSince1970
                print("render time \(end - start)")
                print("render complete \(self.setting.outputURL)")
                self.isLoading = true
                self.themeURL = self.setting.outputURL
                self.setting.saveVideoURL(url: self.setting.outputURL)
                self.viewmodelAV.stop()
                self.viewmodelAV.removePlayerObservers()
                UserDefaults.standard.set(self.setting.outputURL.absoluteString, forKey: "ChristmasVideoURL")
                self.calmThemeURL(frameDuration: frameDuration)
                UserDefaults.standard.set(self.setting.outputURL, forKey: "videoURL")
            }
        }
    }
    
    func calmThemeURL(frameDuration:Double) {
        self.animationSet = .zoomInOut
        
        if audioFileURL == nil {
            self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Lost In A Moment.mp3")
        }else{
            self.audioURL = audioFileURL
        }
        if self.selectedAspectRatio == .square {
            if let path = Bundle.main.path(forResource: "Calm-back_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Calm-front_square", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .landscape {
            if let path = Bundle.main.path(forResource: "Calm-back_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Calm-front_landscape", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .portrait {
            if let path = Bundle.main.path(forResource: "Calm-back_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Calm-front_portrait", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }else if self.selectedAspectRatio == .standard {
            if let path = Bundle.main.path(forResource: "Calm-back_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifImages?.removeAll()
                    self.gifImages = frames
                }
            }
            if let path = Bundle.main.path(forResource: "Calm-front_standard", ofType: "gif") {
                let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
                if let frames = self.extractFrames(from: gifData) {
                    // Use the frames array
                    print("Extracted \(frames.count) frames")
                    self.gifFrontImages?.removeAll()
                    self.gifFrontImages = frames
                }
            }
        }
    
        
        setting.saveToLibrary = false
        setting.fps = 60
        setting.imageloop = Int(50 * frameDuration)
        setting.ratio = selectedAspectRatio
        if !selectedImage.isEmpty {
            imageAnimator = ImageAnimator(renderSettings: setting, gifFrames: gifImages!, gifFrontFrames: gifFrontImages!, audioURL: self.audioURL!, animation:animationSet)
            imageAnimator?.images = self.selectedImage
            print("render time begin")
            let start = Date().timeIntervalSince1970
            imageAnimator?.render {
                let end = Date().timeIntervalSince1970
                print("render time \(end - start)")
                print("render complete \(self.setting.outputURL)")
                self.isLoading = true
                self.themeURL = self.setting.outputURL
                self.setting.saveVideoURL(url: self.setting.outputURL)
                self.viewmodelAV.stop()
                self.viewmodelAV.removePlayerObservers()
                UserDefaults.standard.set(self.setting.outputURL.absoluteString, forKey: "CalmVideoURL")
                self.audioMerge()
                UserDefaults.standard.set(self.setting.outputURL, forKey: "videoURL")
            }
        }
    }
    
    func cleanUpURL(_ urlString: String) -> String? {
        
        var cleanedURL = urlString.replacingOccurrences(of: "file:///", with: "")
        cleanedURL = cleanedURL.removingPercentEncoding ?? cleanedURL
        
        return cleanedURL
    }
    
    func videoProcess(audioURL: URL, frameDuration:Double) {
        setting.saveToLibrary = false
        setting.fps = 60
        setting.imageloop = Int(50 * frameDuration)
        setting.ratio = selectedAspectRatio
        if !selectedImage.isEmpty {
            imageAnimator = ImageAnimator(renderSettings: setting, gifFrames: gifImages!, gifFrontFrames: gifFrontImages!, audioURL: self.audioURL!, animation:animationSet)
            imageAnimator?.images = self.selectedImage
            print("render time begin")
            let start = Date().timeIntervalSince1970
            imageAnimator?.render {
                let end = Date().timeIntervalSince1970
                print("render time \(end - start)")
                print("render complete \(self.setting.outputURL)")
                self.isLoading = false
                self.themeURL = self.setting.outputURL
                self.viewmodelAV.stop()
                self.viewmodelAV.removePlayerObservers()
                self.viewmodelAV.setupPlayer(videoURL: self.setting.outputURL, audioURL: audioURL)
                //self.viewModelAV.seek(to: .zero)
                self.viewmodelAV.play()
                
                UserDefaults.standard.set(self.setting.outputURL, forKey: "videoURL")
            }
        }
    }
    // Function to save Data to a file and return its URL
    func dataToURL(data: Data, filename: String, fileExtension: String) -> URL? {
        // Get the temporary directory for the app
        let tempDirectory = FileManager.default.temporaryDirectory
        // Create a file URL with the provided filename and extension
        let fileURL = tempDirectory.appendingPathComponent(filename).appendingPathExtension(fileExtension)
        do { // Write the data to the file
            try data.write(to: fileURL)
            print("Data saved to: \(fileURL)")
            return fileURL
        } catch {
            print("Error writing data to file: \(error)")
            return nil
        }
    }
    public func audioMerge() {
        
        var selectedTheme : String?
        
        selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme")
        self.audioFileURL = UserDefaults.standard.url(forKey: "\(selectedTheme ?? "Love")AudioURL")
        
        if let cleanedURLString = cleanUpURL(audioFileURL?.absoluteString ?? "") {
            audioFileURL = URL(string: cleanedURLString)
        }
        if selectedTheme == "Love" {
            if audioFileURL == nil {
                self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Beautiful.mp3")
            }else{
                self.audioURL = audioFileURL
            }
            
            if !self.setting.videoArray[0].isEmpty {
                if let LoveVideoURL = self.dataToURL(data: self.setting.videoArray[0], filename: "LoveVideoURL", fileExtension: "mp4") {
                    self.isLoading = false
                    self.viewmodelAV.setupPlayer(videoURL: LoveVideoURL.absoluteURL, audioURL: audioURL!)
                    self.viewmodelAV.play()
                }
            }else{
                
            }
        }else if selectedTheme == "Anniversary" {
            if audioFileURL == nil {
                self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Love Is.mp3")
            }else{
                self.audioURL = audioFileURL
            }
            if !self.setting.videoArray[1].isEmpty {
                if let LoveVideoURL = self.dataToURL(data: self.setting.videoArray[1], filename: "AnniversaryVideoURL", fileExtension: "mp4") {
                    self.isLoading = false
                    self.viewmodelAV.setupPlayer(videoURL: LoveVideoURL.absoluteURL, audioURL: audioURL!)
                    self.viewmodelAV.play()
                }
            }else{
                if let videoURL = UserDefaults.standard.string(forKey: "videoURL") {
                    if let videoURLs = URL(string: videoURL){
                        self.isLoading = false
                        self.viewmodelAV.setupPlayer(videoURL: videoURLs.absoluteURL, audioURL: audioURL!)
                        self.viewmodelAV.play()
                    }
                }
            }
        }else if selectedTheme == "Birthday" {
            if audioFileURL == nil {
                self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Happy Birthday Rock.mp3")
            }else{
                self.audioURL = audioFileURL
            }
            if !self.setting.videoArray[2].isEmpty {
                if let LoveVideoURL = self.dataToURL(data: self.setting.videoArray[2], filename: "BirthdayVideoURL", fileExtension: "mp4") {
                    self.isLoading = false
                    self.viewmodelAV.setupPlayer(videoURL: LoveVideoURL.absoluteURL, audioURL: audioURL!)
                    self.viewmodelAV.play()
                }
            }else{
                if let videoURL = UserDefaults.standard.string(forKey: "videoURL") {
                    if let videoURLs = URL(string: videoURL){
                        self.isLoading = false
                        self.viewmodelAV.setupPlayer(videoURL: videoURLs.absoluteURL, audioURL: audioURL!)
                        self.viewmodelAV.play()
                    }
                }
            }
        }else if selectedTheme == "Celebration" {
            if audioFileURL == nil {
                self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Electroslam.mp3")
            }else{
                self.audioURL = audioFileURL
            }
            if !self.setting.videoArray[3].isEmpty {
                if let LoveVideoURL = self.dataToURL(data: self.setting.videoArray[3], filename: "CelebrationVideoURL", fileExtension: "mp4") {
                    self.isLoading = false
                    self.viewmodelAV.setupPlayer(videoURL: LoveVideoURL.absoluteURL, audioURL: audioURL!)
                    self.viewmodelAV.play()
                }
            }else{
                if let videoURL = UserDefaults.standard.string(forKey: "videoURL") {
                    if let videoURLs = URL(string: videoURL){
                        self.isLoading = false
                        self.viewmodelAV.setupPlayer(videoURL: videoURLs.absoluteURL, audioURL: audioURL!)
                        self.viewmodelAV.play()
                    }
                }
            }
        }else if selectedTheme == "Vintage" {
            if audioFileURL == nil {
                self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/I Get By With a LIttle Help.mp3")
            }else{
                self.audioURL = audioFileURL
            }
            if !self.setting.videoArray[4].isEmpty {
                if let LoveVideoURL = self.dataToURL(data: self.setting.videoArray[4], filename: "VintageVideoURL", fileExtension: "mp4") {
                    self.isLoading = false
                    self.viewmodelAV.setupPlayer(videoURL: LoveVideoURL.absoluteURL, audioURL: audioURL!)
                    self.viewmodelAV.play()
                }
            }else{
                if let videoURL = UserDefaults.standard.string(forKey: "videoURL") {
                    if let videoURLs = URL(string: videoURL){
                        self.isLoading = false
                        self.viewmodelAV.setupPlayer(videoURL: videoURLs.absoluteURL, audioURL: audioURL!)
                        self.viewmodelAV.play()
                    }
                }
            }
        }else if selectedTheme == "Memories" {
            if audioFileURL == nil {
                self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Memories.mp3")
            }else{
                self.audioURL = audioFileURL
            }
            if !self.setting.videoArray[5].isEmpty {
                if let LoveVideoURL = self.dataToURL(data: self.setting.videoArray[5], filename: "MemoriesVideoURL", fileExtension: "mp4") {
                    self.isLoading = false
                    self.viewmodelAV.setupPlayer(videoURL: LoveVideoURL.absoluteURL, audioURL: audioURL!)
                    self.viewmodelAV.play()
                }
            }else{
                if let videoURL = UserDefaults.standard.string(forKey: "videoURL") {
                    if let videoURLs = URL(string: videoURL){
                        self.isLoading = false
                        self.viewmodelAV.setupPlayer(videoURL: videoURLs.absoluteURL, audioURL: audioURL!)
                        self.viewmodelAV.play()
                    }
                }
            }
        }else if selectedTheme == "Christmas" {
            if audioFileURL == nil {
                self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/White Snow.mp3")
            }else{
                self.audioURL = audioFileURL
            }
            if !self.setting.videoArray[6].isEmpty {
                if let LoveVideoURL = self.dataToURL(data: self.setting.videoArray[6], filename: "ChristmasVideoURL", fileExtension: "mp4") {
                    self.isLoading = false
                    self.viewmodelAV.setupPlayer(videoURL: LoveVideoURL.absoluteURL, audioURL: audioURL!)
                    self.viewmodelAV.play()
                }
            }else{
                if let videoURL = UserDefaults.standard.string(forKey: "videoURL") {
                    if let videoURLs = URL(string: videoURL){
                        self.isLoading = false
                        self.viewmodelAV.setupPlayer(videoURL: videoURLs.absoluteURL, audioURL: audioURL!)
                        self.viewmodelAV.play()
                    }
                }
            }
        }else if selectedTheme == "Calm" {
            if audioFileURL == nil {
                self.audioURL = URL(string: "http://157.230.235.143/uploads/songs/Lost In A Moment.mp3")
            }else{
                self.audioURL = audioFileURL
            }
            if !self.setting.videoArray[7].isEmpty {
                if let LoveVideoURL = self.dataToURL(data: self.setting.videoArray[7], filename: "CalmVideoURL", fileExtension: "mp4") {
                    self.isLoading = false
                    self.viewmodelAV.setupPlayer(videoURL: LoveVideoURL.absoluteURL, audioURL: audioURL!)
                    self.viewmodelAV.play()
                }
            }else{
                if let videoURL = UserDefaults.standard.string(forKey: "videoURL") {
                    if let videoURLs = URL(string: videoURL){
                        self.isLoading = false
                        self.viewmodelAV.setupPlayer(videoURL: videoURLs.absoluteURL, audioURL: audioURL!)
                        self.viewmodelAV.play()
                    }
                }
            }
        }
    }
    
    func exportCurrentAsset(to outputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        exportQueue.enqueueExportSession(asset: asset!, to: outputURL, layers: layercomposition, topAnimation: animtionTop, backAnimation: animationBack, selectedTheme: selectedItem, completion: completion)
       }
    
    func createVideo(from images: [UIImage]) {
        let composition = AVMutableComposition()
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        
        var currentTime = CMTime.zero
        var instructions = [AVMutableVideoCompositionInstruction]()
        
        for image in images {
            let asset = createAssetFromImage(image: image, aspectRatio: setting.size)
            let timeRange = CMTimeRange(start: currentTime, duration: CMTime(seconds: 2, preferredTimescale: 600)) // 3 seconds per image
            
            if let assetTrack = asset.tracks(withMediaType: .video).first {
                try? videoTrack.insertTimeRange(timeRange, of: assetTrack, at: currentTime)
                
                let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
                layerInstruction.setTransform(CGAffineTransform.identity, at: currentTime)
                
                let instruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = timeRange
                instruction.layerInstructions = [layerInstruction]
                
                instructions.append(instruction)
            }
            
            currentTime = CMTimeAdd(currentTime, timeRange.duration)
        }
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = instructions
        videoComposition.frameDuration = CMTime(value: 1, timescale: 10)
        videoComposition.renderSize = setting.size
        
        exportVideo(composition: composition, videoComposition: videoComposition)
    }
    
    private func createAssetFromImage(image: UIImage, aspectRatio: CGSize) -> AVAsset {
        let renderer = UIGraphicsImageRenderer(size: setting.size)
        
        let renderedImage = renderer.image { context in
            let rect = AVMakeRect(aspectRatio: aspectRatio, insideRect: CGRect(origin: .zero, size: setting.size))
            image.draw(in: rect)
        }
        
        let imageLayer = CALayer()
        imageLayer.contents = renderedImage.cgImage
        imageLayer.frame = CGRect(origin: .zero, size: setting.size)
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: setting.size)
        parentLayer.addSublayer(imageLayer)
        
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: setting.size)
        
        let layerComposition = AVMutableVideoComposition()
        layerComposition.renderSize = setting.size
        layerComposition.frameDuration = CMTime(value: 1, timescale: 10)
        layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: 3, preferredTimescale: 600))
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction()
        instruction.layerInstructions = [layerInstruction]
        layerComposition.instructions = [instruction]
        
        let composition = AVMutableComposition()
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else { return composition }
        try? videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: instruction.timeRange.duration), of: videoTrack, at: .zero)
        
        return composition
    }
    
    private func exportVideo(composition: AVMutableComposition, videoComposition: AVMutableVideoComposition) {
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("output").appendingPathExtension("mp4")
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            exportStatus = "Failed to create export session"
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    self.exportStatus = "Export completed: \(outputURL)"
                case .failed:
                    self.exportStatus = "Export failed: \(String(describing: exportSession.error))"
                    print(exportSession.error!)
                case .cancelled:
                    self.exportStatus = "Export cancelled"
                default:
                    break
                }
            }
        }
        
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.exportProgress = exportSession.progress
            }
            .store(in: &cancellables)
    }
}
