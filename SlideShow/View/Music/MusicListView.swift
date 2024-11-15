//
//  MusicListView.swift
//  SlideShow
//
//  Created by Shahrukh on 20/06/2024.
//

import SwiftUI
import AVFoundation

struct MusicListView: View {
    @ObservedObject var viewModel: MusicCategoryViewModel 
    @Environment(\.presentationMode) var presentationMode
    @State var audioPlayer: AVPlayer? = nil
    @State var audioPlayerItem: AVPlayerItem? = nil
    @State var playIcon: String = "play.fill"
    @State var currentSong: String = ""
    @Binding var showMusicCategoryView: Bool
    @Binding var showToast: Bool
    @Binding var audioFileURL: String
    //@State var audioFileURL: String = ""
    @State private var showAlert: Bool = false
    @StateObject var themeViewModel = ThemeViewModel.shared
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    Image("Background")
                        .resizable()
                        .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image("IconBack")
                                    .font(.title)
                                    .foregroundColor(.white)
                                
                           
                            }
                            .padding()
                            
                            Spacer()
                            
                            Text("Music")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.leading, 30)
                            
                            Spacer()
                            
                            Button(action: {
                                if audioFileURL == "" {
                                    showAlert = true
                                }else{
                                  //  showMusicCategoryView.toggle()
                                    selectedTab = 0
                                    showToast.toggle()
                                }
                            }) {
                                Text("Add")
                                    .font(.headline)
                                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                    .background(Color("primaryColor"))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                            
                            .padding()
                        }
                       
                        
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach($viewModel.songs,  id: \.id) { $song in
                                    HStack {
                                        
                                        if song.name == currentSong {
                                            if playIcon == "play.fill" {
                                                Image(systemName: playIcon)
                                                    .foregroundColor(.white)
                                                    .frame(width: 20, height: 20)
                                                    .padding(.leading, 8)
                                                    .onTapGesture {
                                                        playIcon = "SmallPause"
                                                        playSong(song)
                                                    }
                                            } else {
                                                Image(playIcon)
                                                    .foregroundColor(.white)
                                                    .frame(width: 25, height: 25)
                                                    .padding(.leading, 8)
                                                    .onTapGesture {
                                                        stopPlayback()
                                                    }
                                            }
                                        } else {
                                            Image(systemName: "play.fill")
                                                .foregroundColor(.white)
                                                .frame(width: 20, height: 20)
                                                .padding(.leading, 8)
                                                
                                        }
                                       
                                        
                                        Text(song.name ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .padding(.leading, 10)
                                            .lineLimit(1)
                                        Spacer()
                                        Text(song.duration ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 10)
                                    }
                                    
                                    .padding(.vertical, 10)
                                    .background((song.name == currentSong && playIcon != "play.fill") ? Color("primaryColor") : Color.gray.opacity(0.3))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 20)
                                    .onTapGesture {
                                        playIcon = "SmallPause"
                                        playSong(song)
                                    }
                                }
                            }
                            
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                     Alert(
                         title: Text("Alert"),
                         message: Text("Plese select any audio"),
                         dismissButton: .default(Text("OK")) {
                             
                         }
                     )
                 }
                .alert(isPresented: $showToast) {
                    Alert(title: Text("Music Selected"), message: Text("Music added to Theme"), dismissButton: .default(Text("Confirm"), action: {
                      //  performPrimaryAction()
                    }))
                }
                
                .alert(isPresented: $showToast) {
                    Alert(
                        title: Text("Music Selected"),
                        message: Text("Would you like to add music in Theme?"),
                        primaryButton: .default(Text("Confirm"), action: {
                            themeViewModel.audioFileURL = URL(string: audioFileURL)
                            if let selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme") {
                                UserDefaults.standard.set(audioFileURL, forKey: "\(selectedTheme)AudioURL")
                            }
                            selectedTab = 0
                            presentationMode.wrappedValue.dismiss()
                        }),
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func playSong(_ song: Song) {
        guard let audioURL = song.file else { return }
        currentSong = song.name ?? ""
        if let url = URL(string: audioURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
            audioPlayerItem = AVPlayerItem(url: url)
            audioFileURL = audioURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            print("songFile \(audioFileURL) songName \(song.name ?? "")")
            audioPlayer = AVPlayer(playerItem: audioPlayerItem)
            audioPlayer?.play()
        }
    }
    
    // Function to stop playback
    func stopPlayback() {
        audioFileURL = ""
        playIcon = "play.fill"
        audioPlayer?.pause()
    }
}

//#Preview {
//    MusicListView(viewModel: MusicCategoryViewModel(), showMusicCategoryView: .constant(false), showToast: .constant(false))
//}
