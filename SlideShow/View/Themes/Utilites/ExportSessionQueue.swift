//
//  ExportSessionQueue.swift
//  SlideShow
//
//  Created by Anuj Joshi on 28/06/24.
//

import Foundation
import AVFoundation
import UIKit

class ExportSessionQueue: ObservableObject {
    static let shared = ExportSessionQueue()

    private var exportSessions: [(AVAsset, URL, (Result<URL, Error>) -> Void)] = []
    private var isExporting: Bool = false
    private var layercomposition = AVMutableVideoComposition()
    private let gifLayer = CALayer()
    private let gifLayer2 = CALayer()
    private let outputLayer = CALayer()
    private var videoSize = CGSize()
    private var selectedItem = String()
    func enqueueExportSession(asset: AVAsset, to outputURL: URL, layers: AVMutableVideoComposition, topAnimation: CAKeyframeAnimation, backAnimation: CAKeyframeAnimation, selectedTheme: String, completion: @escaping (Result<URL, Error>) -> Void) {
        exportSessions.append((asset, outputURL, completion))
        selectedItem = selectedTheme
        processNextSession(topAnimation: topAnimation, backAnimation: backAnimation)
    }
    
    private func processNextSession(topAnimation: CAKeyframeAnimation, backAnimation: CAKeyframeAnimation) {
        guard !isExporting, !exportSessions.isEmpty else { return }
        
        isExporting = true
        let (asset, outputURL, completion) = exportSessions.removeFirst()
    
        exportMedia(from: asset, to: outputURL, topAnimation: topAnimation, backAnimation: backAnimation) { [weak self] result in
            DispatchQueue.main.async {
                completion(result)
                self?.isExporting = false
                self?.processNextSession(topAnimation: topAnimation, backAnimation: backAnimation)
            }
        }
    }
    
    private func exportMedia(from asset: AVAsset, to outputURL: URL, topAnimation: CAKeyframeAnimation, backAnimation: CAKeyframeAnimation, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {

            let composition = AVMutableComposition()
            let track =  asset.tracks(withMediaType: AVMediaType.video)
            print("CC  ", track.count)
            let videoTrack:AVAssetTrack = track[0] as AVAssetTrack
            let timerange = CMTimeRangeMake(start: CMTime.zero, duration: (asset.duration))
            
            let compositionVideoTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())!
            do {
                try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: CMTime.zero)
                compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
            } catch {
                print(error)
            }
            
            // Add default audio file
            var audio: AVURLAsset?
            var audioTimeRange: CMTimeRange?
            if self.selectedItem == "Love"{
                if let audioURL = URL(string: "http://157.230.235.143//uploads//songs/Beautiful.mp3") {
                    audio = AVURLAsset(url: audioURL)
                    let audioDuration = CMTime(seconds: composition.duration.seconds, preferredTimescale: audio!.duration.timescale)
                    audioTimeRange = CMTimeRange(start: .zero, duration: audioDuration)
                }
            }else if self.selectedItem == "Anniversary"{
                if let audioURL = URL(string: "http://157.230.235.143/uploads/songs/Love Is.mp3") {
                    audio = AVURLAsset(url: audioURL)
                    let audioDuration = CMTime(seconds: composition.duration.seconds, preferredTimescale: audio!.duration.timescale)
                    audioTimeRange = CMTimeRange(start: .zero, duration: audioDuration)
                }
            }else if self.selectedItem == "Birthday"{
                if let audioURL = URL(string: "http://157.230.235.143/uploads/songs/Happy Birthday Rock.mp3") {
                    audio = AVURLAsset(url: audioURL)
                    let audioDuration = CMTime(seconds: composition.duration.seconds, preferredTimescale: audio!.duration.timescale)
                    audioTimeRange = CMTimeRange(start: .zero, duration: audioDuration)
                }
            }else if self.selectedItem == "Celebration"{
                if let audioURL = URL(string: "http://157.230.235.143/uploads/songs/Electroslam.mp3") {
                    audio = AVURLAsset(url: audioURL)
                    let audioDuration = CMTime(seconds: composition.duration.seconds, preferredTimescale: audio!.duration.timescale)
                    audioTimeRange = CMTimeRange(start: .zero, duration: audioDuration)
                }//http:\/\/157.230.235.143\/uploads\/songs\/Electroslam.mp3
            }else if self.selectedItem == "Vintage"{
                if let audioURL = URL(string: "http://157.230.235.143/uploads/songs/I Get By With a LIttle Help.mp3") {
                    audio = AVURLAsset(url: audioURL)
                    let audioDuration = CMTime(seconds: composition.duration.seconds, preferredTimescale: audio!.duration.timescale)
                    audioTimeRange = CMTimeRange(start: .zero, duration: audioDuration)
                }//http:\/\/157.230.235.143\/uploads\/songs\/Memories.mp3
            }else if self.selectedItem == "Memories"{
                if let audioURL = URL(string: "http://157.230.235.143/uploads/songs/Memories.mp3") {
                    audio = AVURLAsset(url: audioURL)
                    let audioDuration = CMTime(seconds: composition.duration.seconds, preferredTimescale: audio!.duration.timescale)
                    audioTimeRange = CMTimeRange(start: .zero, duration: audioDuration)
                }
            }else if self.selectedItem == "Christmas"{
                if let audioURL = URL(string: "http://157.230.235.143/uploads/songs/White Snow.mp3") {
                    audio = AVURLAsset(url: audioURL)
                    let audioDuration = CMTime(seconds: composition.duration.seconds, preferredTimescale: audio!.duration.timescale)
                    audioTimeRange = CMTimeRange(start: .zero, duration: audioDuration)
                }
            }else if self.selectedItem == "Calm"{
                if let audioURL = URL(string: "http://157.230.235.143/uploads/songs/Lost In A Moment.mp3") {
                    audio = AVURLAsset(url: audioURL)
                    let audioDuration = CMTime(seconds: composition.duration.seconds, preferredTimescale: audio!.duration.timescale)
                    audioTimeRange = CMTimeRange(start: .zero, duration: audioDuration)
                }
            }

            
            if let audio = audio, let audioTimeRange = audioTimeRange {
                if let audioTrack = audio.tracks(withMediaType: .audio).first {
                    let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                    do {
                        try compositionAudioTrack?.insertTimeRange(audioTimeRange, of: audioTrack, at: .zero)
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                }
            }
            
            //let size = self.newSize!
            self.videoSize = videoTrack.naturalSize
            
            let videolayer = CALayer()
            videolayer.frame = CGRect(x: 250, y: 350, width: self.videoSize.width/2, height: self.videoSize.height/2)
            
           
           // videolayer.position = CGPoint(x: self.videoSize.width + 50, y: self.videoSize.height / 2)
            
            self.gifLayer.frame = CGRect(x: 0, y: 0, width: self.videoSize.width, height: self.videoSize.height)
            self.gifLayer.add(backAnimation, forKey: "contents")
            
            self.gifLayer2.frame = CGRect(x: 0, y: 0, width: self.videoSize.width, height: self.videoSize.height)
            self.gifLayer2.add(topAnimation, forKey: "contents")
            print("Added Layers")
            
            let timeInterval: CFTimeInterval = 2
            var animationGroup = CAAnimationGroup()
           // animationGroup = self.createComplexAnimationGroup(videoSize: self.videoSize)
            animationGroup.animations = [self.createPositionAnimation(), self.createRotationAnimation()]
            animationGroup.duration = 2
            animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
            animationGroup.isRemovedOnCompletion = false
            animationGroup.fillMode = .forwards
            animationGroup.repeatCount = Float.infinity
            
//            if self.selectedItem == "Love"{
//              //  let bgColor = self.hexStringToUIColor(hex: "#F8DCDB")
//              //  self.gifLayer.backgroundColor = bgColor.cgColor
//                videolayer.add(animationGroup, forKey: "animationGroup")
//            }else if self.selectedItem == "Default"{
//                videolayer.add(CABasicAnimation(), forKey: "No Animation")
//            }else if self.selectedItem == "Vintage" {
//                videolayer.add(self.createComplexAnimationGroup(videoSize: self.videoSize), forKey: "complexAnimationGroup")
//            }else if self.selectedItem == "Christmas"{
//                videolayer.add(self.createBouncingAnimationGroup(videoSize: self.videoSize), forKey: "bouncingAnimationGroup")
//            }else if self.selectedItem == "Anniversary"{
//                videolayer.add(self.createAnniversaryComplexAnimationGroup(videoSize: self.videoSize), forKey: "complexAnimationGroup")
//            }else {
//                videolayer.add(self.createUniqueAnimationGroup(videoSize: self.videoSize), forKey: "uniqueAnimationGroup")
//            }
            self.applyRandomTransition(to: videolayer)
           // self.applyMultipleAnimationsToVideoLayer(videoLayer: videolayer)
            print("Videolayer with Animation")
            if self.selectedItem == "Default"{
                self.outputLayer.removeFromSuperlayer()
                self.outputLayer.addSublayer(videolayer)
            }else {
                videolayer.borderWidth = 12
                videolayer.borderColor = UIColor.white.cgColor
                videolayer.backgroundColor = UIColor.clear.cgColor
                self.outputLayer.addSublayer(self.gifLayer)
                self.outputLayer.addSublayer(videolayer)
                self.outputLayer.addSublayer(self.gifLayer2)
            }
            

            
            // layercomposition = AVMutableVideoComposition()
            self.layercomposition.renderSize = self.videoSize
            self.layercomposition.frameDuration = CMTimeMake(value: 1, timescale: 60)
            self.layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: self.outputLayer)
            print("layercomposition animationTool added successfully")
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: composition.duration)
            guard let videotrack = composition.tracks(withMediaType: .video).first else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "CompositionTrackError", code: -1, userInfo: nil)))
                        }
                        return
                    }
            let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
            instruction.layerInstructions = [layerinstruction]
            self.layercomposition.instructions = [instruction]
            
            let saveUrl = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/SlideShow.mp4")
            
            print("SaveURL is ready for export Session")
            self.removeItemIfExisted(saveUrl as URL)
            
            guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHEVCHighestQualityWithAlpha) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "ExportSessionCreation", code: -1, userInfo: nil)))
                }
                return
            }
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
           // exportSession.shouldOptimizeForNetworkUse = true
            exportSession.videoComposition = self.layercomposition
            exportSession.canPerformMultiplePassesOverSourceMediaData = true
           //
            let tempUrl = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/")
            exportSession.directoryForTemporaryFiles = tempUrl
            
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    DispatchQueue.main.async {
                   //     self.outputLayer = nil
                        completion(.success(outputURL))
                    }
                case .failed, .cancelled:
                    DispatchQueue.main.async {
                        completion(.failure(exportSession.error ?? NSError(domain: "ExportSessionError", code: -1, userInfo: nil)))
                    }
                default:
                    break
                }
                self.cleanup(exportSession: exportSession)
            }
        }
    }
    
    private func cleanup(exportSession: AVAssetExportSession) {
        // Cleanup and release resources
        exportSession.cancelExport()
    }
    
//    func createAnimationGroup(positionAnimation: CAKeyframeAnimation, beginTime: CFTimeInterval) -> CAAnimationGroup {
//        let animationGroup = CAAnimationGroup()
//        animationGroup.animations = [positionAnimation, createPositionAnimation()]
//        animationGroup.duration = positionAnimation.duration
//        animationGroup.beginTime = beginTime
//        animationGroup.isRemovedOnCompletion = false
//        animationGroup.fillMode = .forwards
//        animationGroup.repeatCount = 1 // No need to repeat as each animation is specific to a sequence
//        return animationGroup
//    }
//    
//    func applyMultipleAnimationsToVideoLayer(videoLayer: CALayer) {
//        let animationGroups = [
//            createPositionAndRotationAnimationGroup(),
//            createAnimationGroup(positionAnimation: createRotationAnimation(), beginTime: AVCoreAnimationBeginTimeAtZero),
//            createAnimationGroup(positionAnimation: createScaleAnimation(), beginTime: AVCoreAnimationBeginTimeAtZero + 2),
//            createAnimationGroup(positionAnimation: createOpacityAnimation(), beginTime: AVCoreAnimationBeginTimeAtZero + 4),
//            createAnimationGroup(positionAnimation: createUniqueScaleAnimation(), beginTime: AVCoreAnimationBeginTimeAtZero + 6)
//        ]
//
//        for (index, animationGroup) in animationGroups.enumerated() {
//            videoLayer.add(animationGroup, forKey: "animationGroup\(index)")
//        }
//    }

    
    func applyRandomTransition(to layer: CALayer) {
        let transitions = [
            createPositionAndRotationAnimationGroup(),
            createFlyInFromLeftAnimationGroup(),
            createFadeInWiggleFadeOutAnimationGroup(),
            createFlyInFromTopAnimationGroup(),
            createFlyInFromRightAnimationGroup(),
            createFlyInFromBottomAnimationGroup()
        ]
        
     //   let randomIndex = Int(arc4random_uniform(UInt32(transitions.count)))
      //  let selectedTransition = transitions[randomIndex]
        
        for (index, transition) in transitions.enumerated() {
            let randomIndex = Int(arc4random_uniform(UInt32(transitions.count)))
            let selectedTransition = transitions[randomIndex] 
            layer.add(selectedTransition, forKey: "animationGroup\(randomIndex)")
        }
       // layer.add(selectedTransition, forKey: nil)
    }
    func createFlyInFromLeftAnimationGroup() -> CAAnimationGroup {
        let positionAnimation = CAKeyframeAnimation(keyPath: "position.x")
        let width = videoSize.width
        positionAnimation.values = [-250, width / 2, width + 250]
        positionAnimation.keyTimes = [0, 0.5, 1]
        positionAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [0.8, 1.0, 1.2]
        scaleAnimation.keyTimes = [0, 0.5, 1]
        
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotationAnimation.values = [0, CGFloat.pi / 16, 0, -CGFloat.pi / 16, 0]
        rotationAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, scaleAnimation, rotationAnimation]
        animationGroup.duration = 2
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero + 2
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }
    
    func createFadeInWiggleFadeOutAnimationGroup() -> CAAnimationGroup {
        let fadeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        fadeAnimation.values = [0, 1, 1, 0]
        fadeAnimation.keyTimes = [0, 0.25, 0.75, 1]
        
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotationAnimation.values = [0, CGFloat.pi / 16, 0, -CGFloat.pi / 16, 0]
        rotationAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [fadeAnimation, rotationAnimation]
        animationGroup.duration = 2
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero + 4
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }
    
    func createFlyInFromTopAnimationGroup() -> CAAnimationGroup {
        let positionAnimation = CAKeyframeAnimation(keyPath: "position.y")
        let height = videoSize.height
        positionAnimation.values = [-300, height / 2, height + 300]
        positionAnimation.keyTimes = [0, 0.5, 1]
        positionAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        
        let moveAnimation = CAKeyframeAnimation(keyPath: "position.x")
        moveAnimation.values = [self.videoSize.width / 2 - 10, self.videoSize.width / 2, self.videoSize.width / 2 + 10, self.videoSize.width / 2]
        moveAnimation.keyTimes = [0.25, 0.5, 0.75, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, moveAnimation]
        animationGroup.duration = 2
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero + 6
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }
    
    func createFlyInFromRightAnimationGroup() -> CAAnimationGroup {
        let positionAnimation = CAKeyframeAnimation(keyPath: "position.x")
        let width = videoSize.width
        positionAnimation.values = [width + 250, width / 2, -250]
        positionAnimation.keyTimes = [0, 0.5, 1]
        positionAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.2, 1.0, 0.8]
        scaleAnimation.keyTimes = [0, 0.5, 1]
        
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotationAnimation.values = [0, CGFloat.pi / 16, 0, -CGFloat.pi / 16, 0]
        rotationAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, scaleAnimation, rotationAnimation]
        animationGroup.duration = 2
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero + 8
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }
    
    func createFlyInFromBottomAnimationGroup() -> CAAnimationGroup {
        let positionAnimation = CAKeyframeAnimation(keyPath: "position.y")
        let height = videoSize.height
        positionAnimation.values = [height + 300, height / 2, -300]
        positionAnimation.keyTimes = [0, 0.5, 1]
        positionAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.2, 1.0, 0.8]
        scaleAnimation.keyTimes = [0, 0.5, 1]
        
        let fadeAnimation = CAKeyframeAnimation(keyPath: "opacity")
        fadeAnimation.values = [1, 1, 0]
        fadeAnimation.keyTimes = [0, 0.75, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, scaleAnimation, fadeAnimation]
        animationGroup.duration = 2
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero + 10
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }
    
    func createPositionAndRotationAnimationGroup() -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [self.createPositionAnimation(), self.createRotationAnimation()]
        animationGroup.duration = 2
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }
    
    func createPositionAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        let width = videoSize.width
        animation.values = [width + 250, width / 2, -250]
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        animation.duration = 2
        return animation
    }
    
    func createRotationAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [0, CGFloat.pi / 8, 0, -CGFloat.pi / 8, 0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        animation.duration = 2
        return animation
    }
    
    func createScaleAndOpacityAnimationGroup() -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [self.createScaleAnimation(), self.createOpacityAnimation()]
        animationGroup.duration = 2
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }

    func createScaleAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.5, 1.0]
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }

    func createOpacityAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [1.0, 0.5, 1.0]
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }
    
    func createPositionAndScaleAnimationGroup() -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [self.createPositionAnimation(), self.createScaleAnimation()]
        animationGroup.duration = 2
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }
    func createRotationAndOpacityAnimationGroup() -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [self.createRotationAnimation(), self.createOpacityAnimation()]
        animationGroup.duration = 2
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }

    func createPositionRotationAndOpacityAnimationGroup() -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [self.createPositionAnimation(), self.createRotationAnimation(), self.createOpacityAnimation()]
        animationGroup.duration = 2
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }

    func createComplexAnimationGroup(videoSize: CGSize) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [
           // createComplexPositionAnimation(videoSize: videoSize),
            createComplexRotationAnimation(),
            createComplexScaleAnimation(),
            createComplexOpacityAnimation()
        ]
        animationGroup.duration = 5
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }

    func createComplexPositionAnimation(videoSize: CGSize) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position")
        let width = videoSize.width
        let height = videoSize.height
        animation.values = [
            CGPoint(x: width + 250, y: height / 2),
            CGPoint(x: width / 2, y: height + 250),
            CGPoint(x: -250, y: height / 2),
            CGPoint(x: width / 2, y: -250)
        ]
        animation.keyTimes = [0, 0.33, 0.66, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }

    func createComplexRotationAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [0, CGFloat.pi / 4, 0, -CGFloat.pi / 4, 0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }

    func createComplexScaleAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.5, 1.0, 0.5, 1.0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }

    func createComplexOpacityAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [1.0, 0.3, 1.0, 0.3, 1.0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }
    
    func createBouncingAnimationGroup(videoSize: CGSize) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [
            createBouncingPositionAnimation(videoSize: videoSize),
            createBouncingScaleAnimation(),
            createBouncingOpacityAnimation()
        ]
        animationGroup.duration = 2
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }

    func createBouncingPositionAnimation(videoSize: CGSize) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position.y")
        let height = videoSize.height
        animation.values = [height / 2, height / 2 - 30, height / 2, height / 2 - 15, height / 2]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeIn)
        ]
        return animation
    }

    func createBouncingScaleAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.2, 1.0, 1.1, 1.0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeIn)
        ]
        return animation
    }

    func createBouncingOpacityAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [1.0, 0.8, 1.0, 0.9, 1.0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeIn)
        ]
        return animation
    }
    
    func createUniqueAnimationGroup(videoSize: CGSize) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [
            createUniquePositionAnimation(videoSize: videoSize),
            createUniqueScaleAnimation(),
            createUniqueRotationAnimation(),
            createUniqueColorAnimation()
        ]
        animationGroup.duration = 4
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }

    func createUniquePositionAnimation(videoSize: CGSize) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position")
        let width = videoSize.width
        let height = videoSize.height
        animation.values = [
            CGPoint(x: width / 2, y: height / 2),
            CGPoint(x: width / 4, y: height / 4),
            CGPoint(x: width * 3 / 4, y: height / 4),
            CGPoint(x: width / 4, y: height * 3 / 4),
            CGPoint(x: width * 3 / 4, y: height * 3 / 4),
            CGPoint(x: width / 2, y: height / 2)
        ]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }

    func createUniqueScaleAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.5, 1.0, 0.5, 1.0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }

    func createUniqueRotationAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [0, CGFloat.pi / 4, 0, -CGFloat.pi / 4, 0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }

    func createUniqueColorAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "backgroundColor")
        animation.values = [
            UIColor.red.cgColor,
            UIColor.blue.cgColor,
            UIColor.green.cgColor,
            UIColor.yellow.cgColor,
            UIColor.purple.cgColor,
            UIColor.red.cgColor
        ]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }
    
    func createAnniversaryComplexAnimationGroup(videoSize: CGSize) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [
            createAnniversaryComplexPositionAnimation(videoSize: videoSize),
            createAnniversaryComplexScaleAnimation(),
            createAniComplexRotationAnimation(),
            createAniComplexOpacityAnimation(),
            createComplexPathAnimation(videoSize: videoSize)
        ]
        animationGroup.duration = 5
        animationGroup.beginTime = AVCoreAnimationBeginTimeAtZero
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = Float.infinity
        return animationGroup
    }
    
    func createAnniversaryComplexPositionAnimation(videoSize: CGSize) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position")
        let width = videoSize.width
        let height = videoSize.height
        animation.values = [
            CGPoint(x: width / 2, y: height / 2),
            CGPoint(x: width / 3, y: height / 3),
            CGPoint(x: width * 2 / 3, y: height / 3),
            CGPoint(x: width / 3, y: height * 2 / 3),
            CGPoint(x: width * 2 / 3, y: height * 2 / 3),
            CGPoint(x: width / 2, y: height / 2)
        ]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }
    
    func createAnniversaryComplexScaleAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.5, 0.5, 1.0, 1.2, 1.0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }
    func createAniComplexRotationAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.values = [0, CGFloat.pi / 4, 0, -CGFloat.pi / 4, 0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }

    func createAniComplexOpacityAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [1.0, 0.5, 1.0, 0.7, 1.0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }
    func createComplexPathAnimation(videoSize: CGSize) -> CAKeyframeAnimation {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: videoSize.width / 2, y: videoSize.height / 2))
        path.addCurve(to: CGPoint(x: videoSize.width / 2, y: videoSize.height / 2),
                      controlPoint1: CGPoint(x: videoSize.width / 4, y: videoSize.height / 4),
                      controlPoint2: CGPoint(x: videoSize.width * 3 / 4, y: videoSize.height * 3 / 4))
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = 5
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        return animation
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
}
