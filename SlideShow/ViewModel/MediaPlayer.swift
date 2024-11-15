//
//  MediaPlayer.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import Foundation
import AVKit
import Combine

final class MediaPlayer: NSObject, ObservableObject {
    
    static let shared = MediaPlayer()
    
    private var playerItemContext = 0
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0
    @Published var player: AVPlayer?
    
    private var playerItem: AVPlayerItem? {
        willSet {
            if let currentItem = playerItem {
                removePlayerItemObservers(from: currentItem)
            }
        }
        didSet {
            if let newItem = playerItem {
                addPlayerItemObservers(to: newItem)
            }
        }
    }
    private var timeObserverToken: Any?
    private let exportQueue = ExportSessionQueue.shared
    
    private override init() {
        player = AVPlayer()
    }
    
    deinit {
        removePlayerObservers()
    }
    
    //    func setupPlayer(with url: URL) {
    //          // Stop the current player
    //          stop()
    //
    //          // Create a new AVPlayerItem
    //          playerItem = AVPlayerItem(url: url)
    //
    //          // Replace the current item with the new one
    //          player?.replaceCurrentItem(with: playerItem)
    //      }
    func setupPlayer(videoURL: URL, audioURL: URL) {
        // Stop the current player
        stop()
        
        // Create an AVMutableComposition
        let composition = AVMutableComposition()
        
        // Add video track to the composition
        let videoAsset = AVAsset(url: videoURL)
        let videoTrack = videoAsset.tracks(withMediaType: .video).first!
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        try? videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoTrack, at: .zero)
        
        // Add audio track to the composition
        let cleanedURLString = audioURL.absoluteString.replacingOccurrences(of: "\\s--\\sfile:///", with: "", options: .regularExpression)
        if let url = URL(string: cleanedURLString), UIApplication.shared.canOpenURL(url) {
            print("Valid URL: \(url)")
            let audioAsset = AVAsset(url: url.absoluteURL)
            let audioTrack = audioAsset.tracks(withMediaType: .audio).first!
            let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: audioTrack, at: .zero)
        } else {
            print("Invalid URL")
        }
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        
        exportSession.outputURL = videoURL
        exportSession.outputFileType = .mov
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("videoURL completed \(videoURL)")
            case .failed, .cancelled:
                print("videoURL failed \(videoURL)")
            default:
                break
            }
        }
        // Create an AVPlayerItem from the composition
        playerItem = AVPlayerItem(asset: composition)
        
        // Replace the current item with the new one
        player?.replaceCurrentItem(with: playerItem)
        
        // Update duration
        duration = composition.duration.seconds
        
        // Add time observer
        addTimeObserver()
        
        // Listen for the end of the video
                   NotificationCenter.default.addObserver(
                       forName: .AVPlayerItemDidPlayToEndTime,
                       object: playerItem,
                       queue: .main
                   ) { _ in
                       self.player?.seek(to: .zero)
                       self.player?.play()
                   }
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
    }
    
    private func addPlayerItemObservers(to item: AVPlayerItem) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEndTime(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )
    }
    
    private func removePlayerItemObservers(from item: AVPlayerItem) {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    @objc private func playerItemDidPlayToEndTime(_ notification: Notification) {
        // Handle item end
        stop()
    }
    
    func removePlayerObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1.0, preferredTimescale: timeScale)
        
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
}
