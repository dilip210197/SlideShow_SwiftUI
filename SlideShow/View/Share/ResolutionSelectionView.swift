//
//  ResolutionSelectionView.swift
//  SlideShow
//
//  Created by Shahrukh on 21/06/2024.
//

import SwiftUI

struct ResolutionSelectionView: View {
    @Binding var selectedResolution: String
    @Binding var selectedResolutionSize: CGSize
    @Binding var showResolutionView: Bool
    
    var resolutions = [
        ("Ultra - 4k", "10 sec to export", "25 MB"),
        ("Full HD - 1080p", "5 sec to export", "14 MB"),
        ("HD - 720p", "5 sec to export", "10 MB"),
        ("Large - 540p", "5 sec to export", "8 MB"),
        ("Medium - 480p", "5 sec to export", "6 MB")
    ]
    let resolutionsSize: [CGSize] = [
        CGSize(width: 3840, height: 2160), // Ultra 4K
        CGSize(width: 1920, height: 1080), // 1080p
        CGSize(width: 1280, height: 720),  // 720p
        CGSize(width: 960, height: 540),    // 540p
        CGSize(width: 640, height: 480)    // 480p
    ]

    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#74C0CD")
                .edgesIgnoringSafeArea(.all)
                
            
            VStack {
                Spacer()
                
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Text("Resolution")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    Text("The higher the resolution, the better the quality of the exported video.")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(resolutions.indices, id: \.self) { index in
                            let resolution = resolutions[index]
                            VStack(spacing: 0) {
                                ZStack {
                                    if resolution.0 == selectedResolution {
                                        GradientBackground()
                                    } else {
                                        Color(hex: "#74C0CD")
                                    }
                                    ResolutionRow(resolution: resolution.0, exportTime: resolution.1, fileSize: resolution.2)
                                        .padding()
                                }
                                Rectangle()
                                    .foregroundColor(Color(hex: "#43D1D6"))
                                    .frame(height: 1)
                                    .padding(.horizontal, 30)
                            }
                            .contentShape(Rectangle()) // Ensures the entire area is tappable
                            .onTapGesture {
                                print("Resolution \(resolution.0) tapped at index \(index)")
                                selectedResolution = resolution.0
                                selectedResolutionSize = resolutionsSize[index]
                                showResolutionView.toggle()
                            }
                        }
                    }
                }
            }
        }
        .cornerRadius(40)
        .padding(.leading, 10)
        .padding(.trailing, 10)
    }
}


struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#4A9DB0"), Color(hex: "#63ABAE"), Color(hex: "#4A9DB0")]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct ResolutionRow: View {
    var resolution: String
    var exportTime: String
    var fileSize: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(resolution)
                    .font(.headline)
                Text(exportTime)
                    .font(.caption) // Make the export time text smaller
                    .foregroundColor(.black)
            }
            Spacer()
            Text(fileSize)
                .font(.headline)
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}
//#Preview {
//    ResolutionSelectionView(selectedResolution: .constant(""), showResolutionView: .constant(false))
//}

