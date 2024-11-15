//
//  ShareView.swift
//  SlideShow
//
//  Created by Shahrukh on 20/06/2024.
//

import SwiftUI
import AVKit
import Combine
import ImageIO
import Photos
import AVFoundation

struct ShareView: View {
    
    @State var isShowFrameRate: Bool = false
    @State var isShowResolutionView: Bool = false
    @Binding var showShareView: Bool
    @State var selectedResolution: String = "Full HD - 1080p"
    @State var selectedResolutionSize: CGSize = CGSize(width: 1920, height: 1080)
    @State var selectedFrameRate: Int = 25
    @State var themeURL: URL?
    @State private var showAlert: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State var itemsToShare: [Any] = ["Edited video by SlideShow"]
    @State private var isShareSheetPresented = false
    @StateObject private var viewModelAV = MediaPlayer.shared
    @State private var isDownloading = false
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                HStack {
                    Image("IconClose")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .padding()
                        .onTapGesture {
                            showShareView.toggle()
                        }
                    Spacer()
                }
                Spacer()
            }
            
            VStack {
                Spacer()
                Text("Share")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                // Illustration of hands holding a phone
                Image("ImageShare")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .padding()
                                
                // Resolution and Frame Rate options
                VStack(spacing: 20) {
                    HStack {
                        Text("Resolution")
                            .foregroundColor(.white)
                            .font(.title3)
                        Spacer()
                        Text(selectedResolution)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(height: 80)
                    .background(Color.init(hex: "#414042"))
                    .cornerRadius(20)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) { // Slow down animation duration
                            isShowResolutionView.toggle()
                        }
                    }
                                        
                    HStack {
                        Text("Frame Rate")
                            .foregroundColor(.white)
                            .font(.title3)
                        Spacer()
                        Text("\(selectedFrameRate) FPS")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(height: 80)
                    .background(Color.init(hex: "#414042"))
                    .cornerRadius(20)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) { // Slow down animation duration
                            isShowFrameRate.toggle()
                        }
                    }
                }
                .padding(.horizontal)
                Spacer()
                
                // Save and Share buttons
                HStack {
                    Spacer()
                    VStack {
                        BigButton(action: {
                            isDownloading = true
                            self.downloadVideo()
                        }, image: "ButtonSave")
                        Text("Save")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack {
                        BigButton(action: {
                            isShareSheetPresented = true
                        }, image: "ButtonShare")
                        Text("Share")
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $isShareSheetPresented) {
                        ActivityViewController(activityItems: [UserDefaults.standard.url(forKey: "videoURL")!])
                    }
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .background(Color.clear)
            .edgesIgnoringSafeArea(.all)
            
            if isShowFrameRate {
                VStack {
                    Spacer()
                    FrameRateSelectionView(selectedFrameRate: $selectedFrameRate, isShowFrameRate: $isShowFrameRate)
                        .transition(.move(edge: .bottom))
                }
                .background(Color.black.opacity(0.5))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) { // Slow down animation duration
                        isShowFrameRate.toggle()
                    }
                }
                
            }
            
            if isShowResolutionView {
                VStack {
                    Spacer()
                    ResolutionSelectionView(selectedResolution: $selectedResolution, selectedResolutionSize: $selectedResolutionSize, showResolutionView: $isShowResolutionView)
                        .frame(height: 475)
                        .cornerRadius(30)
                        .transition(.move(edge: .bottom))
                    
                }
                .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) { // Slow down animation duration
                        isShowResolutionView.toggle()
                    }
                }
            }
        }
        .onAppear{
            self.viewModelAV.stop()
        }
        .alert(isPresented: $showAlert) {
             Alert(
                 title: Text("Download Complete"),
                 message: Text("The video has been downloaded successfully."),
                 dismissButton: .default(Text("OK")) {
                     presentationMode.wrappedValue.dismiss()
                 }
             )
         }
        .overlay {
            Group {
                if isDownloading {
                    ZStack{
                        Color.black.opacity(0.75)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView("Download In Progress...")
                            .bold()
                            .foregroundColor(.accentColor)
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                            .controlSize(.extraLarge)
                            .tint(.accentColor)
                    }
                }
            }
        }
    }
    
    func cleanUpURL(_ urlString: String) -> String {
        
        var cleanedURL = urlString.replacingOccurrences(of: "file:///", with: "")
        cleanedURL = cleanedURL.removingPercentEncoding ?? cleanedURL
        
        return cleanedURL
    }
    
    private func downloadVideo(isFromShare: Bool = false) {
        // Implement your download logic here
        print("Download button tapped")
        print("Download themeURL \(themeURL ?? UserDefaults.standard.url(forKey: "videoURL")!)")
        if let urls = themeURL {
            //guard var audioURL = UserDefaults.standard.url(forKey: "audioURL") else { return }
            //print("audioURL userDefault \(audioURL)")
            let selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme")
            var audioURL = URL(string: "http://157.230.235.143/uploads/songs/Beautiful.mp3")
            if selectedTheme != "" || selectedTheme != nil {
                audioURL = UserDefaults.standard.url(forKey: "\(selectedTheme ?? "")AudioURL")
            }else{
                audioURL = URL(string: "http://157.230.235.143/uploads/songs/Beautiful.mp3")
            }
            if audioURL == nil {
                if selectedTheme == "Love" {
                    audioURL = URL(string: "http://157.230.235.143/uploads/songs/Beautiful.mp3")
                }else if selectedTheme == "Anniversary" {
                    audioURL = URL(string: "http://157.230.235.143/uploads/songs/Love Is.mp3")
                }else if selectedTheme == "Birthday" {
                    audioURL = URL(string: "http://157.230.235.143/uploads/songs/Happy Birthday Rock.mp3")
                }else if selectedTheme == "Celebration" {
                    audioURL = URL(string: "http://157.230.235.143/uploads/songs/Electroslam.mp3")
                }else if selectedTheme == "Vintage" {
                    audioURL = URL(string: "http://157.230.235.143/uploads/songs/I Get By With a LIttle Help.mp3")
                }else if selectedTheme == "Memories" {
                    audioURL = URL(string: "http://157.230.235.143/uploads/songs/Memories.mp3")
                }else if selectedTheme == "Christmas" {
                    audioURL = URL(string: "http://157.230.235.143/uploads/songs/White Snow.mp3")
                }else if selectedTheme == "Calm" {
                    audioURL = URL(string: "http://157.230.235.143/uploads/songs/Lost In A Moment.mp3")
                }
            }
            let cleanedURLString = cleanUpURL(audioURL?.absoluteString ?? "")
            
            audioURL = URL(string: cleanedURLString)!
            downloadAudio(from: audioURL!.absoluteURL) { downloadResult in
                switch downloadResult {
                case .success(let localAudioURL):
                    print("Audio downloaded to: \(localAudioURL.path)")
                    // Verify the downloaded audio
                    verifyAudioAsset(url: localAudioURL) { isValid, error in
                        if isValid {
                            print("Audio asset is valid. Proceeding to merge.")
                            
                            // Define output URL
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let outputURL = documentsDirectory.appendingPathComponent("merged_output.mp4")
                            
                            // Merge video and audio
                            mergeVideoAndAudio(videoURL: urls, audioURL: localAudioURL, outputURL: outputURL, resolution: selectedResolutionSize) { mergeResult in
                                switch mergeResult {
                                case .success(let mergedURL):
                                    print("Successfully merged video and audio: \(mergedURL.path)")
                                    //let url = URL(string: mergedURL.path)
                                            print("atFileURL \(String(describing: mergedURL))")
                                            PHPhotoLibrary.shared().performChanges({
                                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: mergedURL)
                                            }) { saved, error in
                                                isDownloading = false
                                                if saved {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                        showAlert = true
                                                    }
                                                    print("Saved")
                                                }else{
                                                    print("Failed to merge video and audio: \(String(describing: error?.localizedDescription))")
                                                }
                                            }
                                case .failure(let error):
                                    print("Failed to merge video and audio: \(error.localizedDescription)")
                                }
                            }
                        } else {
                            print("Audio asset is invalid: \(String(describing: error))")
                        }
                    }
                    
                case .failure(let error):
                    print("Failed to download audio: \(error)")
                }
            }
        }else{
            
        }
    }
    
    func downloadAudio(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let localURL = localURL else {
                completion(.failure(NSError(domain: "DownloadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to download file"])))
                return
            }
            
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
            
            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.moveItem(at: localURL, to: destinationURL)
                print("Audio downloaded to: \(destinationURL.path)")
                completion(.success(destinationURL))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func verifyAudioAsset(url: URL, completion: @escaping (Bool, Error?) -> Void) {
        let asset = AVAsset(url: url)
        let keys = ["tracks"]
        
        asset.loadValuesAsynchronously(forKeys: keys) {
            var error: NSError?
            let status = asset.statusOfValue(forKey: "tracks", error: &error)
            if status == .loaded {
                let audioTracks = asset.tracks(withMediaType: .audio)
                if !audioTracks.isEmpty {
                    print("Audio track loaded successfully.")
                    completion(true, nil)
                } else {
                    print("No audio tracks found in the asset.")
                    completion(false, NSError(domain: "VerificationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No audio tracks found"]))
                }
            } else {
                print("Failed to load tracks: \(error?.localizedDescription ?? "Unknown error")")
                completion(false, error)
            }
        }
    }

    func mergeVideoAndAudio(videoURL: URL, audioURL: URL, outputURL: URL, resolution: CGSize, completion: @escaping (Result<URL, Error>) -> Void) {
        let mixComposition = AVMutableComposition()
        
        // Add video track
        let videoAsset = AVURLAsset(url: videoURL)
        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
            completion(.failure(NSError(domain: "MergeError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot load video track"])))
            return
        }
        
        let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        try? videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoTrack, at: .zero)
        
        // Add audio track
        let audioAsset = AVURLAsset(url: audioURL)
        guard let audioTrack = audioAsset.tracks(withMediaType: .audio).first else {
            completion(.failure(NSError(domain: "MergeError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot load audio track"])))
            return
        }
        
        let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        try? audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: audioTrack, at: .zero)

        exportVideo(localURL: outputURL, asset: mixComposition, resolution: resolution) { finalURL in
            completion(.success(finalURL!))
        }
    }


    func loadLocalVideo(url: URL) -> AVAsset? {
        let asset = AVAsset(url: url)
        return asset
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
    
    func exportVideo(localURL: URL ,asset: AVAsset, resolution: CGSize, completion: @escaping (URL?) -> Void) {
        
        
        let presetName: String
        switch resolution {
        case CGSize(width: 3840, height: 2160):
            presetName = AVAssetExportPreset3840x2160 // Ultra 4K
        case CGSize(width: 1920, height: 1080):
            presetName = AVAssetExportPreset1920x1080 // 1080p
        case CGSize(width: 1280, height: 720):
            presetName = AVAssetExportPreset1280x720  // 720p
        case CGSize(width: 960, height: 540):
            presetName = AVAssetExportPreset960x540   // 540p
        case CGSize(width: 640, height: 480):
            presetName = AVAssetExportPreset640x480   // 480p
        default:
            presetName = AVAssetExportPresetHighestQuality
        }
        
        if let videoComposition = createVideoComposition(asset: asset, selectedFrameRate: selectedFrameRate, resolution: resolution) {
            
            if (AVAssetExportSession(asset: asset, presetName: presetName) != nil) {
                
                // Create an export session with the Ultra 4K preset
                guard let exportSession = AVAssetExportSession(asset: asset, presetName: presetName) else {
                    print("Failed to create export session.")
                    completion(nil)
                    return
                }
                
                // Prepare the output URL for the exported video
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let outputURL = documentsPath.appendingPathComponent("\(presetName).mp4")
                
                // Remove existing file if present
                removeItemIfExisted(outputURL)
                
                // Set up the export session parameters
                exportSession.outputURL = outputURL
                exportSession.outputFileType = .mp4
                exportSession.shouldOptimizeForNetworkUse = true
                
                asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                    var error: NSError? = nil
                    let status = asset.statusOfValue(forKey: "duration", error: &error)
                    
                    if status == .loaded {
                        // Set video composition if needed (otherwise can skip this)
                        exportSession.videoComposition = videoComposition
                        
                        // Start the export process asynchronously
                        exportSession.exportAsynchronously {
                            switch exportSession.status {
                            case .completed:
                                print("Video exported successfully: \(outputURL)")
                                completion(outputURL)
                            case .failed:
                                print("Export failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                                completion(nil)
                            case .cancelled:
                                print("Export canceled.")
                                completion(nil)
                            default:
                                break
                            }
                        }
                    } else {
                        print("Failed to load asset duration: \(String(describing: error))")
                        completion(nil)
                    }
                }
            } else {
                print("Preset not compatible with the asset.")
                completion(nil)
            }
        }
    }
    
    func createVideoComposition(asset: AVAsset, selectedFrameRate: Int, resolution: CGSize) -> AVMutableVideoComposition? {
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            return nil
        }
        
        // Desired render size for 1:1 aspect ratio
        var squareSize = CGSize(width: 1080, height: 1920) // Example size for a 1:1 square frame
        if let aspectRatio = UserDefaults.standard.string(forKey: "aspectRatio") {
            if aspectRatio == "standard" {
                squareSize = CGSize(width: 1440, height: 1080) // 4:3 standard
            }else if aspectRatio == "portrait" {
                squareSize = CGSize(width: 1080, height: 1920) // 9:16 portrait
            }else if aspectRatio == "landscape" {
                squareSize = CGSize(width: 1920, height: 1080) // 16:9 landscape
            }else if aspectRatio == "square" {
                squareSize = CGSize(width: 2160, height: 2160) // 16:9 square
            }else{
                squareSize = CGSize(width: 1080, height: 1920)
            }
        }
        
        let videoTrackSize = videoTrack.naturalSize
        //let renderSize = resolution
        //let videoTransform = videoTrack.preferredTransform
        
        let scaleX = squareSize.width / videoTrackSize.width
        let scaleY = squareSize.height / videoTrackSize.height
        
        let scale = min(scaleX, scaleY)  // Scale to fit while maintaining aspect ratio
        let scaledVideoSize = CGSize(width: videoTrackSize.width * scale, height: videoTrackSize.height * scale)
       
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: scale, y: scale)
        
        
        let translationX = (squareSize.width - videoTrackSize.width * scale) / 2
        let translationY = (squareSize.height - videoTrackSize.height * scale) / 2
        transform = transform.translatedBy(x: translationX, y: translationY)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = squareSize
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: CMTimeScale(selectedFrameRate))
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        layerInstruction.setTransform(transform, at: .zero)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        return videoComposition
    }
}


struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
