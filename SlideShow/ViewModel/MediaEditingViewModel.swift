//
//  MediaEditingViewModel.swift
//  SlideShow
//
//  Created by Shahrukh on 10/06/2024.
//

import Foundation
import UIKit
import CoreGraphics
import SwiftUI
import Combine

class MediaEditingViewModel: ObservableObject {

    struct TextOverlaySetting {
        var text: String
        var position: CGSize
        var size: CGFloat
        var scale: CGFloat
        var rotation: Angle
        var hasBackground: Bool
        var color: Color
    }
    
    struct EmojiOverlaySetting {
        var emoji: String = ""
        var scale: CGFloat = 1.0
        var position: CGSize = .zero
        var rotation: Angle = .zero
    }

    @Published var mainImage: UIImage = UIImage(systemName: "questionmark")!
    @Published var index: Int = 0
    @Published var textOverlay: TextOverlaySetting = TextOverlaySetting(text: "Type here...", position: .zero, size: 80, scale: 2.0, rotation: .zero, hasBackground: true, color: .white)
    @Published var emojiOverlay: EmojiOverlaySetting = EmojiOverlaySetting()

    @Published var angle: CGFloat? = 0.0
    @Published var size: CGSize = CGSize(width: 0, height: 0)
    @Published var setToFill: Bool = false
    @Published var showingTextInputView: Bool = false
    @Published var showingEmojiInputView: Bool = false
    @Published var isEditing: Bool = false
    @Published var isEditingText: Bool = false

    private var isFlipped = true
    private var cancellables: Set<AnyCancellable> = []
    private var history: [(UIImage, Int, TextOverlaySetting)] = []
    private let historyDepth = 5
    private var historyIndex = 0
    private var disableSubscribers = false

    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        $mainImage
            .dropFirst()
            .sink { [weak self] newValue in
                if !(self?.disableSubscribers ?? false) {
                    self?.saveToHistory()
                }
            }
            .store(in: &cancellables)

        $index
            .dropFirst()
            .sink { [weak self] newValue in
                if !(self?.disableSubscribers ?? false) {
                    self?.saveToHistory()
                }
            }
            .store(in: &cancellables)

        $textOverlay
            .dropFirst()
            .sink { [weak self] newValue in
                if !(self?.disableSubscribers ?? false) {
                    self?.saveToHistory()
                }
            }
            .store(in: &cancellables)
        $emojiOverlay
            .dropFirst()
            .sink { [weak self] newValue in
                if !(self?.disableSubscribers ?? false) {
                    self?.saveToHistory()
                }
            }
            .store(in: &cancellables)
    }

    private func saveToHistory() {
        if history.count == historyDepth {
            history.removeFirst()
        }
        
        // Store a tuple of the observed values
        history.append((mainImage, index, textOverlay))
        historyIndex = history.count - 1
    }

    func undo() {
        guard historyIndex > 0 else { return }
        historyIndex -= 1
        restoreFromHistory()
    }

    func redo() {
        guard historyIndex < history.count - 1 else { return }
        historyIndex += 1
        restoreFromHistory()
    }

    private func restoreFromHistory() {
        disableSubscribers = true
        let (savedImage, savedIndex, savedTextOverlay) = history[historyIndex]
        mainImage = savedImage
        index = savedIndex
        textOverlay = savedTextOverlay
        disableSubscribers = false
    }

    
    func rotateImage() {
        
        let radians = 90 * CGFloat.pi / 180
        var newSize = CGRect(origin: .zero, size: mainImage.size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.mainImage.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: radians)
        // Draw the image at its center
        mainImage.draw(in: CGRect(x: -self.mainImage.size.width / 2, y: -self.mainImage.size.height / 2, width: self.mainImage.size.width, height: self.mainImage.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        mainImage = rotatedImage!
    }
    
    func toggleFitImage() {
        self.setToFill.toggle()
    }
    
    func flipped() {
        mainImage = UIImage(cgImage: mainImage.cgImage!, scale: 1.0, orientation: isFlipped ? .upMirrored : .up)
        isFlipped.toggle()
    }
    
    
    func adjustTextSize(for image: UIImage, in size: CGSize) {
        let imageSize = image.size
        let aspectWidth = size.width / imageSize.width
        let aspectHeight = size.height / imageSize.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        let baseTextSize: CGFloat = 40
        self.textOverlay.size = baseTextSize * aspectRatio * 2 // Adjust the multiplier as needed
        self.size = size
    }
    
    func applyWatermarks() -> UIImage {
        self.applyEmojiWatermark()
        return self.applyTextWatermark()
    }
    
    func applyTextWatermark() -> UIImage {
        guard showingTextInputView && isEditing else { return mainImage }
        let image = mainImage
        let textSize = textOverlay.size
        let rotation = textOverlay.rotation
        let text = textOverlay.text
        let position = textOverlay.position
        let scale = textOverlay.scale
        //
        let renderer = UIGraphicsImageRenderer(size: image.size)
        //Add text to image
        let img = renderer.image { ctx in
            image.draw(at: .zero)
            
            let scaleFactorX = image.size.width / size.width
            let scaleFactorY = image.size.height / size.height
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: textSize * scale * ((image.size.height > image.size.width) ? scaleFactorY : scaleFactorX)),
                .foregroundColor: UIColor(textOverlay.color),
                .backgroundColor: UIColor.black.withAlphaComponent(textOverlay.hasBackground ? 0.5 : 0.0)
            ]
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let textSize = attributedString.size()
            
            let containerWidth = size.width
            let containerHeight = size.height
            
            let textXPosition = (containerWidth / 2 + position.width) * scaleFactorX - textSize.width / 2
            let textYPosition = (containerHeight / 2 + position.height) * scaleFactorY - textSize.height / 2
            let textPosition = CGPoint(x: textXPosition, y: textYPosition)
            
            // Save the current context state
            ctx.cgContext.saveGState()
            
            // Move the origin to the text position
            ctx.cgContext.translateBy(x: textPosition.x + textSize.width / 2, y: textPosition.y + textSize.height / 2)
            
            // Apply the rotation transform
            ctx.cgContext.rotate(by: rotation.radians)
            
            // Move the origin back and draw the text
            ctx.cgContext.translateBy(x: -textSize.width / 2, y: -textSize.height / 2)
            attributedString.draw(at: CGPoint(x: -textSize.width / 2, y: -textSize.height / 2))
            
            // Restore the context state
            ctx.cgContext.restoreGState()
        }
        self.mainImage = img
        return img
    }
    
    
    func applyEmojiWatermark() -> UIImage? {
        
        // Define the size of the renderer to match the image size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: self.mainImage.size.width, height: self.mainImage.size.height))
        
        // Calculate the scale factors based on the container size and the actual image size
        let scaleFactorX = self.mainImage.size.width / size.width
        let scaleFactorY = self.mainImage.size.height / size.height
        
        // Calculate the effective width and height of the image in the container
        let containerAspectRatio = size.width / size.height
        let imageAspectRatio = self.mainImage.size.width / self.mainImage.size.height
        
        var effectiveImageWidth: CGFloat
        var effectiveImageHeight: CGFloat
        var horizontalOffset: CGFloat = 0
        var verticalOffset: CGFloat = 0
        
        if imageAspectRatio > containerAspectRatio {
            // Image is wider than the container, so scale based on height
            effectiveImageHeight = size.height
            effectiveImageWidth = effectiveImageHeight * imageAspectRatio
            horizontalOffset = (size.width - effectiveImageWidth) / 2
        } else {
            // Image is taller than the container, so scale based on width
            effectiveImageWidth = size.width
            effectiveImageHeight = effectiveImageWidth / imageAspectRatio
            verticalOffset = (size.height - effectiveImageHeight) / 2
        }
        
        return renderer.image { context in
            // Draw the original image in the rendering context
            self.mainImage.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.mainImage.size.width, height: self.mainImage.size.height)))
            
            let selectedEmojie = emojiOverlay.emoji
            if !selectedEmojie.isEmpty {
                // Load the emoji image
                let emojiImage = UIImage(named: selectedEmojie) ?? UIImage()
                
                // Calculate the size of the emoji based on the scale factor and emojieScale
                let emojiSize = CGSize(width: 200 * emojiOverlay.scale * scaleFactorY,
                                       height: 200 * emojiOverlay.scale * scaleFactorY)
                
                let emojiePosition = emojiOverlay.position
                print("emojie position \(emojiOverlay.position.width)")
                // Calculate the actual position of the emoji within the visible image area
                var value = 0.0
                
                if emojiePosition.width < -50 && emojiePosition.width > -100 {
                    value = ((emojiePosition.width - horizontalOffset) / size.width * self.mainImage.size.width) + 30.0
                } else
                
                if emojiePosition.width > -50 && emojiePosition.width < 0 {
                    value = ((emojiePosition.width - horizontalOffset) / size.width * self.mainImage.size.width) + 45.0
                }
                
                else if emojiePosition.width > 0 && emojiePosition.width < 50 {
                    value = (emojiePosition.width - horizontalOffset) / size.width * self.mainImage.size.width + self.mainImage.size.width/5
                    
                } else if emojiePosition.width > 50 && emojiePosition.width < 100 {
                    value = (emojiePosition.width - horizontalOffset) / size.width * self.mainImage.size.width + self.mainImage.size.width/4
                }
                else {
                    value = (emojiePosition.width - horizontalOffset) / size.width * self.mainImage.size.width + self.mainImage.size.width/3
                }
                
                let adjustedPositionX = value
                let emojiePositionY = (emojiePosition.height + size.height / 2) * scaleFactorY - emojiSize.height
                let adjustedPositionY = (emojiePosition.height - verticalOffset) / size.height * self.mainImage.size.height/2
                let emojiRect = CGRect(origin: CGPoint(x: adjustedPositionX , y: emojiePositionY ), size: emojiSize)
                
                // Clip to the main image rect
                let mainImageRect = CGRect(origin: .zero, size: self.mainImage.size)
                context.cgContext.saveGState()
                context.cgContext.clip(to: mainImageRect)
                
                // Apply rotation and translation to the context
                context.cgContext.translateBy(x: emojiRect.midX, y: emojiRect.midY)
                context.cgContext.rotate(by: CGFloat(emojiOverlay.rotation.radians))
                context.cgContext.translateBy(x: -emojiRect.midX, y: -emojiRect.midY)
                
                // Draw the emoji in the adjusted rectangle
                emojiImage.draw(in: emojiRect)
                
                // Restore the context
                context.cgContext.restoreGState()
                self.emojiOverlay = EmojiOverlaySetting()
            }
        }
    }
    
}
