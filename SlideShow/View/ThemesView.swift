//
//  ThemesView.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import SwiftUI
import AVKit
import Combine
import ImageIO
import Photos

struct ThemesView: View {
    @Binding var selectedItem: String?
    @State private var selectedImages: [UIImage] = []
    @StateObject var viewModel = ThemeViewModel.shared
    @StateObject private var viewModelAV = MediaPlayer.shared
    @Binding var themeURL: URL?
    @State var asset: AVAsset?
    @Binding var isLoading: Bool
    @State var project: Project? = nil
    @State private var ratio: Ratio?
    @StateObject var animationStore = AnimationStore.shared
    //@Binding var selectedTab: Int
    @StateObject var waterMarkLogo: MediaEditingViewModel = MediaEditingViewModel()
    @State var setting = RenderSettings()
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    VideoPlayer(player: viewModelAV.player)
                }
                Spacer()
                ThemeSelectionView(selectedItem: $selectedItem, items: [("Love_Theme", "Love")])
                    .frame(height: 170)
                    .onChange(of: selectedItem, {
                        DispatchQueue.main.async {
                            self.viewModel.isLoading = true
                            self.project?.selectedTheme = selectedItem ?? ""
                            UserDefaults.standard.set(selectedItem, forKey: "selectedTheme")
                            self.viewModel.audioMerge()
                            //self.viewModel.setupVideo(viewModel: viewModelAV, selectedTheme: selectedItem, selectedImages: self.selectedImages, animation: [.fadeInOut,.shake,.slowZoom,.zoomInOut].randomElement() ?? .fadeInOut, frameDuration: self.project?.imageTimer ?? 3.0)
                        }
                    })
                    /*.overlay(
                        Group {
                            WaterMarkerLabel(settings: waterMarkLogo)
                        }, alignment: .bottomTrailing)*/
                
            }
            
        }.onDisappear {
            self.viewModelAV.stop()
        }.onAppear {
            self.selectImages()
//            if ratio != nil {
                DispatchQueue.main.async {
                    self.viewModel.isLoading = false
                    print("\(String(describing: self.project?.selectedTheme))")
                    //self.viewModel.setupVideo(viewModel: viewModelAV, selectedTheme: self.project?.selectedTheme, selectedImages: self.selectedImages, animation: [.fadeInOut,.shake,.slowZoom,.zoomInOut].randomElement() ?? .fadeInOut, frameDuration: self.project?.imageTimer ?? 3.0)
                    //self.viewModel.loveThemeURL(viewModel: viewModelAV, selectedTheme: self.project?.selectedTheme, selectedImages: self.selectedImages, animation: [.fadeInOut,.shake,.slowZoom,.zoomInOut].randomElement() ?? .fadeInOut, frameDuration: self.project?.imageTimer ?? 3.0)
                }
//            }
        }
        .environmentObject(ImageProject(project: project!))
    }
    
    func selectImages() {
        self.isLoading = true
        DispatchQueue.main.async {
            let imageArray: [UIImage] = convertDataToUIImage(dataArray: self.project!.image)
            ratio = self.project?.ratio
            self.selectedImages = imageArray
            self.viewModel.setupImages(selectedImages: self.selectedImages, ratio: ratio!)
           // self.setupVideo()
        }
    }
    
    func convertDataToUIImage(dataArray: [Data]) -> [UIImage] {
        return dataArray.compactMap { UIImage(data: $0) }
    }
    
}


