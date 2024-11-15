//
//  FormatView.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import SwiftUI
import AVKit

struct FormatView: View {
    
    @StateObject private var viewModelAV = MediaPlayer.shared
    @State private var selectedBackgroundColor: Color = .gray
    
    @StateObject var viewModel = ThemeViewModel.shared
    @State var project: Project
    @State var selectedImages: [UIImage]
    @State var selectedPortrait: Int?
    @State private var ratio: Ratio?
    //@Binding var selectedTab: Int
    @State var aspectRatio:RenderSettings.AspectRatio
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
                HStack{
                    Text("Aspect: \(aspectRatio.rawValue)")
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                    Spacer()
                }
                HStack {
                    HStack(alignment: .bottom) {
                        VStack {
                            Button {
                                selectedPortrait = 0
                                aspectRatio = .standard
                                self.changeAspectRatio()
                            } label: {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.clear)
                                    .frame(width: 60, height: 45)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(selectedPortrait == 0 ? .accent : .gray, style: StrokeStyle(lineWidth: 2))
                                    )
                                    .background(selectedPortrait == 0 ?
                                                LinearGradient(gradient: Gradient(colors: [Color.accent, Color.accent.opacity(0.5), .black.opacity(0.1), .black,]), startPoint: .topTrailing, endPoint: .bottomLeading) : nil
                                    )
                                    .cornerRadius(10)
                            }
                            
                            Text("4:3")
                                .font(.body)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Standard")
                                .font(.body)
                                .foregroundColor(.gray)
                        }

                        Spacer()
                        VStack{
                            Button {
                                selectedPortrait = 1
                                aspectRatio = .portrait

                                self.changeAspectRatio()
                            } label: {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.clear)
                                    .frame(width: 50, height: 89)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(selectedPortrait == 1 ? .accent : .gray, style: StrokeStyle(lineWidth: 2))
                                    )
                                    .background(selectedPortrait == 1 ?
                                                LinearGradient(gradient: Gradient(colors: [Color.accent, Color.accent.opacity(0.5), .black.opacity(0.1), .black,]), startPoint: .topTrailing, endPoint: .bottomLeading) : nil
                                    )
                                    .cornerRadius(10)
                            }
                            
                            Text("9:16")
                                .font(.body)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Portrait")
                                .font(.body)
                                .foregroundColor(.gray)
                            
                        }
                        Spacer()
                        
                        VStack{
                            Button {
                                selectedPortrait = 2
                                aspectRatio = .landscape

                                self.changeAspectRatio()
                            } label: {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.clear)
                                    .frame(width: 89, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(selectedPortrait == 2 ? .accent : .gray, style: StrokeStyle(lineWidth: 2))
                                    )
                                    .background(selectedPortrait == 2 ?
                                                LinearGradient(gradient: Gradient(colors: [Color.accent, Color.accent.opacity(0.5), .black.opacity(0.1), .black,]), startPoint: .topTrailing, endPoint: .bottomLeading) : nil
                                    )
                                    .cornerRadius(10)
                            }
                            
                            Text("16:9")
                                .font(.body)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Landscape")
                                .font(.body)
                                .foregroundColor(.gray)
                        }

                        Spacer()
                        
                        VStack {
                            Button {
                                selectedPortrait = 3
                                aspectRatio = .square

                                self.changeAspectRatio()
                            } label: {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.clear)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(selectedPortrait == 3 ? .accent : .gray, style: StrokeStyle(lineWidth: 2))
                                    )
                                    .background(selectedPortrait == 3 ?
                                                LinearGradient(gradient: Gradient(colors: [Color.accent, Color.accent.opacity(0.5), .black.opacity(0.1), .black]), startPoint: .topTrailing, endPoint: .bottomLeading) : nil
                                    )
                                    .cornerRadius(10)
                            }
                            
                            Text("1:1")
                                .font(.body)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Square")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }.onAppear {
                    if let aspectRatioValue = UserDefaults.standard.string(forKey: "aspectRatio") {
                        if aspectRatioValue == "standard" {
                            aspectRatio = .standard
                        }else if aspectRatioValue == "portrait" {
                            aspectRatio = .portrait
                        }else if aspectRatioValue == "landscape" {
                            aspectRatio = .landscape
                        }else if aspectRatioValue == "square" {
                            aspectRatio = .square
                        }else{
                            aspectRatio = .portrait
                            self.changeAspectRatio()
                        }
                    }else{
                        aspectRatio = .portrait
                        self.changeAspectRatio()
                    }
                }
            }
            
        }.onDisappear {
            self.viewModelAV.stop()
        }.onAppear{
            self.viewModelAV.play()
        }
    }
    
    func changeAspectRatio() {
        DispatchQueue.main.async {
            self.viewModelAV.stop()
            self.viewModel.isLoading = true
            
            switch aspectRatio{
            case .standard:
                selectedPortrait = 0
                UserDefaults.standard.set("standard", forKey: "aspectRatio")
                self.viewModel.selectedAspectRatio = .standard
            case .portrait:
                selectedPortrait = 1
                UserDefaults.standard.set("portrait", forKey: "aspectRatio")
                self.viewModel.selectedAspectRatio = .portrait
            case .landscape:
                selectedPortrait = 2
                UserDefaults.standard.set("landscape", forKey: "aspectRatio")
                self.viewModel.selectedAspectRatio = .landscape
            case .square:
                selectedPortrait = 3
                UserDefaults.standard.set("square", forKey: "aspectRatio")
                self.viewModel.selectedAspectRatio = .square
            }
        }
        //self.viewModel.selectedAspectRatio = aspectRatio
        DispatchQueue.main.async {
            let imageArray: [UIImage] = convertDataToUIImage(dataArray: self.project.image)
            self.project.ratio = Ratio(rawValue: selectedPortrait!)!
            ratio = self.project.ratio
            self.selectedImages = imageArray
            self.setting.videoArray.removeAll()
            print("self.setting.videoArrayRemove \(self.setting.videoArray)")
            self.viewModel.setupImages(selectedImages: self.selectedImages, ratio: ratio!)
            //self.viewModel.setupVideo(viewModel: viewModelAV, selectedTheme: self.project.selectedTheme, selectedImages: selectedImages, animation: [.fadeInOut,.shake,.slowZoom,.zoomInOut].randomElement() ?? .fadeInOut, frameDuration: self.project.imageTimer)
            self.viewModel.loveThemeURL(viewModel: viewModelAV, selectedTheme: self.project.selectedTheme, selectedImages: selectedImages, animation: [.fadeInOut,.shake,.slowZoom,.zoomInOut].randomElement() ?? .fadeInOut, frameDuration: self.project.imageTimer)
        }
    }
    
    public func convertDataToUIImage(dataArray: [Data]) -> [UIImage] {
         return dataArray.compactMap { UIImage(data: $0) }
     }
}

