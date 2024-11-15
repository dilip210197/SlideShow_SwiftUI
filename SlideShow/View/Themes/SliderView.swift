//
//  SliderView.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import SwiftUI

//struct SliderView: View {
//    @ObservedObject var viewModel: PlayerSliderViewModel
//    @State private var sliderValue: Double = 0.0
//       @State private var timerValue: Int = 0
//       @State private var isPlaying: Bool = false
//       @State private var timer: Timer? = nil
//    
//    init(player: MediaPlayer) {
//        viewModel = .init(player: player)
//    }
//    
//    var body: some View {
//        HStack {
//            // Play button
//            Button(action: {
//                togglePlayPause()
//            }) {
//                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                    .font(.subheadline)
//                    .padding()
//            }
//            Slider(value: $viewModel.progressValue) { didChange in
//                viewModel.didSliderChanged(didChange)
//            } .frame(height: 20) // Adjust the height of the slider
//
//            
//            // Timer text
//            Text("\(timerValue) s")
//                .font(.footnote)
//                .foregroundColor(.white)
//                .padding()
//        }//.padding()
//        
//    }
//    
//    
//    private func togglePlayPause() {
//        isPlaying.toggle()
//        if isPlaying {
//            startTimer()
//        } else {
//            stopTimer()
//        }
//    }
//
//    private func startTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            timerValue += 1
//        }
//    }
//
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//}
