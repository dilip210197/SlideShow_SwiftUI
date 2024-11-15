//
//  MainView.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import SwiftUI
import UIKit
import AVFoundation
import PhotosUI
import AVKit
import ImageIO

class ImageProject: ObservableObject {
    @Published var project: Project
    
    init(project: Project) {
        self.project = project
    }
}

struct MainView: View {
    @State private var selectedImages: [UIImage?] = []
    @StateObject var viewModel = ThemeViewModel.shared
    @StateObject var mediaEditingViewModel = MediaEditingViewModel()
    @State private var isLoading = false
    @State var project: Project
    @StateObject var animationStore = AnimationStore.shared
    @State private var showShareView: Bool = false
    @State private var themeURL: URL?
    @StateObject private var viewModelAV = MediaPlayer.shared
    @State private var ratio: Ratio?
    @State private var showAlert = false
    @State var selectedItem: String?
    @State var showMusicCategoryView: Bool = true
    @State var showToast: Bool = false
    @State var hideNaviView: Bool = true
    @State var setting = RenderSettings()
    //    @StateObject private var videomaker = VideoMaker().shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack{
            ZStack {
                Image("Background")
                    .resizable()
                TabView(selection: $selectedTab) {
                    ThemesView(selectedItem: $selectedItem, themeURL: $themeURL, isLoading: $isLoading, project: self.project)
                        .tag(0)
                        .tabItem {
                            Label("Themes", systemImage: "photo.stack")
                        }
                        .environmentObject(animationStore)
                        .onAppear {
                            hideNaviView = true
                        }
                    MediaItemDisplayView(showMusicView: .constant(false), project : self.$project,setRatio: self.project.ratio)
                        .tag(1)

                        .tabItem {
                            Label("Media", systemImage: "menucard")
                        }
                        .onAppear {
                            hideNaviView = false
                        }
                        .onDisappear{
                            hideNaviView = true
                        }
                    //Text("Music Selector")
                    MusicCategoryView(showMusicCategoryView: $showMusicCategoryView, showToast: $showToast,selectedTab: $selectedTab)
                        .tag(2)
                        .background(content: {
                            Color.black
                        })
                        .tabItem {
                        Label("Music", systemImage: "music.note.list")
                        .onAppear {
                            print("$selectedTab$selectedTab \($selectedTab)")
                            hideNaviView = true
                        }
                    }
                    FormatView(project: self.project, selectedImages: self.selectedImages.compactMap{ $0 }, aspectRatio: viewModel.selectedAspectRatio)
                        .tag(3)
                        .tabItem {
                            Label("Format", systemImage: "aspectratio")
                        }
                        .onAppear {
                            hideNaviView = true
                        }
                    TimerView(project: self.project, photoDuration: Float(self.project.imageTimer), selectedImages: self.selectedImages.compactMap{ $0 })
                        .tag(4)
                        .tabItem {
                            Label("Timer", systemImage: "timer.square")
                        }
                        .onAppear {
                            hideNaviView = true
                        }
                }.accentColor(Color(red: 0.0, green: 244, blue: 249))
                    .onAppear(perform: {
                        UITabBar.appearance().barTintColor = .gray
                    })
                    .foregroundColor(.black)
                    .environmentObject(ImageProject(project: project))
            }
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if !hideNaviView {
                        HStack {
                            Button {
                                mediaEditingViewModel.undo()
                            } label: {
                                Image(systemName: "arrow.uturn.backward")
                            }
                            .padding(20)
                            Button {
                                mediaEditingViewModel.redo()
                            } label: {
                                Image(systemName: "arrow.uturn.forward")
                            }
                        }
                    }
                }
            }
            .navigationBarItems(leading: Button(action: {
                showAlert = true
            }, label: {
                Image(systemName: "chevron.left")
            }), trailing: Button(action: {
                showShareView.toggle()
            }, label: {
                Image("IconShare")
                    .resizable()
                    .scaledToFit()
            }))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Alert"),
                    message: Text("Are you sure you want to exit this slideshow?"),
                    primaryButton: .destructive(Text("Yes")) {
                        self.setting.removeAllFrameVideos()
                        let window = UIApplication.shared.connectedScenes
                            .filter { $0.activationState == .foregroundActive }
                            .map { $0 as? UIWindowScene }
                            .compactMap { $0 }
                            .first?.windows
                            .filter { $0.isKeyWindow }
                            .first
                        let nvc = window?.rootViewController?.children.first as? UINavigationController
                        nvc?.popToRootViewController(animated: true)
                    },
                    secondaryButton: .cancel()
                )
            }
            .disabled(viewModel.isLoading)
            .overlay {
                Group {
                    if viewModel.isLoading {
                        ZStack{
                            // Black screen with 75% opacity
                            Color.black.opacity(0.75)
                                .edgesIgnoringSafeArea(.all)
                            ProgressView("Theme Generating...")
                                .bold()
                                .foregroundColor(.accentColor)
                                .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                                .controlSize(.extraLarge)
                                .tint(.accentColor)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showShareView) {
                ShareView(showShareView: $showShareView, themeURL: viewModel.themeURL)
            }
            .onDisappear {
                self.viewModelAV.stop()
                self.viewModelAV.player?.replaceCurrentItem(with: nil)
            }
        }
    }
}
