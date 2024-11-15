//
//  WaterMarkerLabel.swift
//  SlideShow
//
//  Created by Shahrukh on 25/06/2024.
//

import Foundation
import SwiftUI


struct WaterMarkerLabel: View {
    @ObservedObject var settings: MediaEditingViewModel
    
    @State private var currentScale: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero
    @State private var currentPosition: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .trailing){
            
            //}
            Text("settings.text")
                .font(.headline)
                .fontDesign(.serif)
                //.font(.system(size: settings.textOverlay.size))
                .foregroundColor(.white)
                //.background(Color.black.opacity(settings.textOverlay.hasBackground ? 0.5 : 0.0))
                .frame(alignment: .bottomTrailing)
                .background(Color.black.opacity(0.3))
//                .scaleEffect(settings.textOverlay.scale * currentScale)
//                .rotationEffect(settings.textOverlay.rotation + currentRotation)
                //.offset(x: settings.textOverlay.position.width + currentPosition.width, y: settings.textOverlay.position.height + currentPosition.height)
//                .gesture(
//                    SimultaneousGesture(
//                        MagnificationGesture()
//                            .onChanged { value in
//                                currentScale = value.magnitude
//                            }
//                            .onEnded { _ in
//                                settings.textOverlay.scale *= currentScale
//                                currentScale = 1.0
//                            },
//                        RotationGesture()
//                            .onChanged { angle in
//                                currentRotation = angle
//                            }
//                            .onEnded { _ in
//                                settings.textOverlay.rotation += currentRotation
//                                currentRotation = .zero
//                            }
//                    )
//                    .simultaneously(with: DragGesture()
//                        .onChanged { value in
//                            currentPosition = value.translation
//                        }
//                        .onEnded { _ in
//                            settings.textOverlay.position.width += currentPosition.width
//                            settings.textOverlay.position.height += currentPosition.height
//                            currentPosition = .zero
//                        }
//                    )
//                    .simultaneously(with: TapGesture()
//                        .onEnded { _ in
//                            settings.isEditingText = true
//                        })
//                )
        }
    }
}
