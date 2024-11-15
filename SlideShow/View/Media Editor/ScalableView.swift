//
//  ScalableView.swift
//  SlideShow
//
//  Created by Shahrukh on 10/06/2024.
//

import SwiftUI

struct ScalableView: View {
    @ObservedObject var settings: MediaEditingViewModel
    
    @State private var currentScale: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero
    @State private var currentPosition: CGSize = .zero
    
    var body: some View {
        VStack {
//            if !settings.emojiOverlay.emoji.isEmpty {
//                ZStack {
//                    ZStack(alignment: .topLeading) {
//                        Image(settings.emojiOverlay.emoji)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 200, height: 200)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 0)
//                                    .stroke(Color.white, lineWidth: 1)
//                            )
//                        
//                        GeometryReader { geo in
//                            Button(action: {
//                                // Action to delete the image
//                                settings.emojiOverlay.emoji = .init()
//                            }) {
//                                Image(systemName: "xmark")
//                                    .foregroundColor(.red)
//                                    .padding(6)
//                                    .background(Color.white)
//                                    .clipShape(Circle())
//                                    .shadow(radius: 2)
//                                
//                            }
//                            .offset(x: -10, y: -10) // Offset to place the button at (0, 0) of the rectangle
//                        }
//                    }
//                    .scaleEffect(settings.emojiOverlay.scale * currentScale)
//                    .rotationEffect(settings.emojiOverlay.rotation + currentRotation) // Apply both the accumulated and the current rotation
//                    
//                    .offset(x: settings.emojiOverlay.position.width + currentPosition.width, y: settings.emojiOverlay.position.height + currentPosition.height) // Offset for dragging
//                    .gesture(
//                        SimultaneousGesture(
//                            MagnificationGesture()
//                                .onChanged { value in
//                                    currentScale = value.magnitude
//                                }
//                                .onEnded { _ in
//                                    settings.emojiOverlay.scale *= currentScale
//                                    currentScale = 1.0
//                                },
//                            RotationGesture()
//                                .onChanged { angle in
//                                    currentRotation = angle
//                                }
//                                .onEnded { _ in
//                                    settings.emojiOverlay.rotation += currentRotation
//                                    currentRotation = .zero
//                                }
//                        )
//                        .simultaneously(with: DragGesture()
//                            .onChanged { value in
//                                currentPosition = value.translation
//                            }
//                            .onEnded { _ in
//                                settings.emojiOverlay.position.width += currentPosition.width
//                                settings.emojiOverlay.position.height += currentPosition.height
//                                currentPosition = .zero
//                            }
//                        )
//                    )
//                }
//            }
        }
    }
}

