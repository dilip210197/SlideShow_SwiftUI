//
//  TimerView.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import SwiftUI
import AVKit
import Combine
import ImageIO
import Photos

struct TimerView: View {
    @StateObject private var viewModelAV = MediaPlayer.shared
    @State var project: Project? = nil
    //@Binding var selectedTab: Int
    // States for the slider values
       @StateObject var viewModel = ThemeViewModel.shared
       @State var photoDuration: Float = 0
       @State private var slideshowDuration: Double = 15.0
       @State var selectedImages: [UIImage]
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    VideoPlayer(player: viewModelAV.player)
                }
                
                // Slider UI
                VStack {
                    
                    Slider(value: $photoDuration, in:  1...10 ,step: 0.1 , onEditingChanged: { changed in
                        
                        if changed == false{
                            DispatchQueue.main.async {
                                self.viewModel.isLoading = true
                                self.project?.imageTimer = Double(photoDuration)
                                //self.viewModel.setupVideo(viewModel: viewModelAV, selectedTheme: self.project?.selectedTheme, selectedImages: selectedImages, animation: [.fadeInOut,.shake,.slowZoom,.zoomInOut].randomElement() ?? .fadeInOut,frameDuration: Double(photoDuration))
                                self.viewModel.loveThemeURL(viewModel: viewModelAV, selectedTheme: self.project?.selectedTheme, selectedImages: self.selectedImages, animation: [.fadeInOut,.shake,.slowZoom,.zoomInOut].randomElement() ?? .fadeInOut, frameDuration: self.project?.imageTimer ?? 3.0)
                            }
                        }
                    })
                        .accentColor(.accentColor)
                      //  .padding()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Photos Duration")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(String(format: "%.1f", photoDuration))s")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .bold()
                        }
                        
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Slideshow Duration")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(String(format: "%.1f", photoDuration * Float(self.selectedImages.count)))s")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .bold()
                        }
                    }
                }
                .padding()
            }
        }.onDisappear {
            self.viewModelAV.stop()
        }
        .onAppear {
            if selectedImages.isEmpty{
                selectImages()
            }
            
        }
    }
    
    func selectImages() {
//        self.isLoading = true
        DispatchQueue.main.async {
            let imageArray: [UIImage] = convertDataToUIImage(dataArray: self.project!.image)
//            ratio = self.project?.ratio
            self.selectedImages = imageArray
//            self.viewModel.setupImages(selectedImages: self.selectedImages, ratio: ratio!)
           // self.setupVideo()
        }
    }
    
    func convertDataToUIImage(dataArray: [Data]) -> [UIImage] {
        return dataArray.compactMap { UIImage(data: $0) }
    }
}

//#Preview {
//    TimerView()
//}
