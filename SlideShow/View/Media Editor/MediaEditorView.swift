//
//  MediaEditorView.swift
//  SlideShow
//
//  Created by Oliver Moscow on 7/14/24.
//

import SwiftUI

struct MediaEditorView: View {
    @ObservedObject var settings: MediaEditingViewModel
    @Binding var imageProject: ImageProject
    @State var selectedTab: TopEditButtonsView.SelectedState = .add

    @StateObject var viewModel = ThemeViewModel.shared
    
    @Binding var isEditing:Bool
    
    var body: some View {
        
        Text("demo")
        
//        VStack {
//            TopEditButtonsView(selected: $selectedTab)
//            
//            //MARK: - Tab specific edit buttons
//            VStack {
//                switch selectedTab {
//                case .add:
//                    HStack {
//                        BigButton(action: {
//                            settings.showingTextInputView.toggle()
//                        }, image: "ButtonText")
//                        BigButton(action: {
//                            settings.showingEmojiInputView.toggle()
//                        }, image: "ButtonEmoji")
//                    }
//                    
//                case .trim:
//                    Text("Work in progress")
//                        .foregroundStyle(.white)
//                case .rotate:
//                    HStack {
//                        BigButton(action: {
//                            settings.rotateImage()
//                        }, image: "ButtonRotate")
//                        BigButton(action: {
//                            settings.toggleFitImage()
//                        }, image: "ButtonFit")
//                        BigButton(action: {
//                            settings.flipped()
//                        }, image: "ButtonFlip")
//                    }
//                    
//                    
////                case .time:
////                    DurationView()
//                    
//                    
//                case .volume:
//                    DurationView(title: "Volume")
//                    
//                }
//            }
//            
//            Spacer()
//            //MARK: - Done Button
//            BigButton(action: {
//                let img = settings.applyWatermarks()
//                if let data = img.pngData() {
//                    settings.isEditing.toggle()
//                    imageProject.project.image[settings.index] = data
//                }
//                isEditing = true
//                self.viewModel.selectedImage = imageProject.project.image.compactMap({ UIImage(data: $0) })
//            }, image: selectedTab == .add ? "ButtonDone" : "ButtonDoneCheck")
//        }
//        .frame(height: 300)
//        .padding(.horizontal)
//        .background(
//            LinearGradient(
//                gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.08),Color.white.opacity(0)]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//        )
    }
}

//#Preview {
//    VStack {
//        Color.white
//        MediaEditorView(settings: MediaEditingViewModel(), imageProject: image, selectedTab: .add)
//    }.background(Color.black)
//}
//}
