//
//  NewProjectView.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/12/24.
//

import SwiftUI
import Photos

struct NewProjectView: View {
    @Environment(\.modelContext) var context
    @State var projectName = "Project \(Date.now.formatted(date: .numeric, time: .omitted))"
    @State var assets: [PHAsset]
    @State var images = [UIImage]()
    @State var selectedPortrait: Int?
    @State var next = false
    @State var project: Project? = nil
    @StateObject private var animationStore = AnimationStore.shared

    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    ScrollView {
                        VStack(alignment: .center, spacing: 10) {
                            Spacer()
                                .frame(height: geometry.size.height * 0.05)
                            
                            Text("Project name")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.white)
                            
                            Text("Give an amazing name to your new creation")
                                .foregroundStyle(.gray)
                            
                            Spacer()
                                .frame(height: 20)
                            
                            TextField("Project \(Date.now.formatted(date: .numeric, time: .omitted))", text: $projectName)
                                .padding(.horizontal, 10)
                                .foregroundStyle(.white)
                                .frame(height: 50)
                                .background(.black.opacity(0.8))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(.gray, style: StrokeStyle(lineWidth: 1))
                                        .opacity(0.8)
                                )
                            
                            Spacer()
                                .frame(height: 40)
                            
                            Text("Aspect Ratio")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.white)
                            
                            Text("The format of the video you're about to make")
                                .foregroundStyle(.gray)
                            
                            Spacer()
                                .frame(height: 40)
                            
                            HStack(alignment: .bottom) {
                                Button {
                                    selectedPortrait = 0
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
                                Spacer()
                                
                                Button {
                                    selectedPortrait = 1
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
                                Spacer()
                                
                                Button {
                                    selectedPortrait = 2
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
                                Spacer()
                                Button {
                                    selectedPortrait = 3
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
                            }
                            .padding()
                            
                            Spacer()
                                .frame(height: 20)
                            
                            Rectangle()
                                .fill(.accent)
                                .frame(height: 1.5)
                                .edgesIgnoringSafeArea(.horizontal)
                            
                            Spacer()
                                .frame(height: 20)
                            
                            HStack {
                                PortraitCardGroup(selectedIndex: $selectedPortrait) {
                                    PortraitCard(ratio: "4:3", description: "Standard", index: 0, selectedIndex: $selectedPortrait)
                                    Spacer()
                                    PortraitCard(ratio: "9:16", description: "Portrait", index: 1, selectedIndex: $selectedPortrait)
                                    Spacer()
                                    PortraitCard(ratio: "16:9", description: "Landscape", index: 2, selectedIndex: $selectedPortrait)
                                    Spacer()
                                    PortraitCard(ratio: "1:1", description: "Sqaure", index: 3, selectedIndex: $selectedPortrait)
                                }
                            }
                            .padding()
                        }
                        .padding()
                    }
                    .onAppear {
                        selectedPortrait = 1
                        
                        let imageManager = PHImageManager.default()
                        let options = PHImageRequestOptions()
                        options.isSynchronous = false
                        options.deliveryMode = .highQualityFormat
                        let targetSize = CGSize(width: 1024, height: 1024)

                        Task { @MainActor in
                            for asset in assets {
                                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options:     options) { (img, info) in
                                    if let img = img {
                                        images.append(img)
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width)
                    .scrollDisabled(true)
                    .background (
                        LinearGradient(gradient: Gradient(colors: [.black.opacity(0.7), .black]), startPoint: .top, endPoint: .bottom)
                    )
                    .toolbarRole(.editor)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Set up your project")
                                .font(.system(size: 20))
                                .bold()
                                .foregroundStyle(.white)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                Task {
                                    var imagesData = [Data]()
                                    var timerCount:Double = 0
                                    images.forEach { image in
                                        imagesData.append(image.pngData() ?? Data())
                                        timerCount = 3.0
                                    }
                                    print("timerset",timerCount)
                                    let project = Project(name: projectName,
                                                          image: imagesData,
                                                          ratio: Ratio(rawValue: selectedPortrait ?? 0)!,
                                                          dateCreated: Date(),timer : timerCount, selectedTheme: "")
                                    self.project = project
                                    context.insert(project)
                                    next = true
                                }
                            } label: {
                                Text("Start")
                                    .bold()
                                    .frame(width: 80, height: 40)
                                    .background(.accent)
                                    .cornerRadius(10)
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                    
                    ProgressView()
                        .showIf(next)
                }
            }
        }
        .navigationDestination(isPresented: $next) { MainView(project: self.project ?? Project(name: "", image: [], ratio: .landscape, dateCreated: Date(), timer: 0, selectedTheme: "")).environmentObject(animationStore) }
    }
}
