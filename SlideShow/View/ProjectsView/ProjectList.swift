//
//  ProjectList.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/18/24.
//

import SwiftUI

struct ProjectList: View {
    @Environment(\.modelContext) var context
    @Binding var showRenameView: Bool
    @Binding var showEditView: Bool
    @Binding var idxToEdit: Int
    @State var showMedia = false
    var projects: [Project]
    @State var project: Project? = nil
    @StateObject private var animationStore = AnimationStore.shared
    @StateObject var viewModel = ThemeViewModel.shared
    @StateObject private var viewModelAV = MediaPlayer.shared
    @State private var ratio: Ratio?
    @State private var selectedImages: [UIImage] = []
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: [GridItem(.flexible())]) {
                ForEach(Array(projects.enumerated()), id: \.1) { index, project in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(project.name)
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.white)
                            
                            Text(project.dateCreated.formatted(date: .long, time: .shortened))
                                .font(.footnote)
                                .bold()
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Button {
                            showEditView = true
                            idxToEdit = index
                        } label: {
                            Circle()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(Color.accentColor)
                                .opacity(0.5)
                                .overlay {
                                    Image(systemName: "ellipsis")
                                        .tint(.white)
                                }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Image(uiImage: UIImage(data: project.image[0])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.width * 0.7)
                        .cornerRadius(25)
                        .onTapGesture {
                            self.project = project
                            showMedia = true
                            viewModel.isLoading = true
                            selectImages()
                            //viewModel.loveThemeURL(viewModel: viewModelAV, selectedTheme: self.project?.selectedTheme, selectedImages: self.selectedImages, animation: [.fadeInOut,.shake,.slowZoom,.zoomInOut].randomElement() ?? .fadeInOut, frameDuration: self.project?.imageTimer ?? 3.0)
                        }
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
            .fullScreenCover(isPresented: $showRenameView) {
                NavigationStack {
                    RenameProjectView(project: projects[idxToEdit],
                                      idxToEdit: idxToEdit,
                                      projectName: projects[idxToEdit].name,
                                      showingRenameView: $showRenameView,
                                      showEditView: $showEditView)
                }
            }
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
            .navigationDestination(isPresented: $showMedia){ MainView(project: self.project ?? Project(name: "", image: [], ratio: .landscape, dateCreated: Date(), timer: 0, selectedTheme: ""), selectedItem: self.project?.selectedTheme ?? "") }.environmentObject(animationStore)
//            .navigationDestination(isPresented: $showMedia) { MainView(project: self.project ?? Project(name: "", image: [], ratio: .landscape, dateCreated: Date(), timer: 0, selectedTheme: self.project!.selectedTheme)).environmentObject(animationStore) }
            
        }
    }
    func selectImages() {
        DispatchQueue.main.async {
            let imageArray: [UIImage] = convertDataToUIImage(dataArray: self.project!.image)
            ratio = self.project?.ratio
            self.selectedImages = imageArray
            self.viewModel.setupImages(selectedImages: self.selectedImages, ratio: ratio!)
           // self.setupVideo()
            self.viewModel.loveThemeURL(viewModel: viewModelAV, selectedTheme: self.project?.selectedTheme, selectedImages: self.selectedImages, animation: .fadeInOut, frameDuration: self.project?.imageTimer ?? 3.0)
        }
    }
    func convertDataToUIImage(dataArray: [Data]) -> [UIImage] {
        return dataArray.compactMap { UIImage(data: $0) }
    }
}
