//
//  MusicCategoryView.swift
//  SlideShow
//
//  Created by Shahrukh on 19/06/2024.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct MusicCategoryView: View {
    @StateObject var viewModel = MusicCategoryViewModel()
    @Binding var showMusicCategoryView: Bool
    @Binding var showToast: Bool
    @State var audioFileURL: String = ""
    @Binding var selectedTab: Int
    var body: some View {
        //NavigationView {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            GeometryReader { geo in
                ZStack {
                    VStack {
//                        HStack (alignment: .center, spacing: 20) {
//                            VStack (spacing: 0) {
//                                Text("Moods")
//                                    .font(.headline)
//                                    .foregroundColor(.white)
//                                Image("Icondot")
//                                    .frame(width: 20,height: 20)
//                            }
//                            Text("iTunes")
//                                .font(.headline)
//                                .foregroundColor(.gray)
//                            
//                            Text("Imported music")
//                                .font(.headline)
//                                .foregroundColor(.gray)
//                            Spacer()
//                        }
//                        .padding(.leading, 20)
//                        
//                        HStack {
//                            Text("Most Popular")
//                                .font(.headline)
//                                .padding()
//                                .frame(width: geo.size.width - 20)
//                                .background(
//                                    LinearGradient(
//                                        gradient: Gradient(colors: [Color(hex: "#29EFF6"), Color(hex: "27AAE1")]),
//                                        startPoint: .leading,
//                                        endPoint: .trailing
//                                    )
//                                )
//                                .cornerRadius(8)
//                                .foregroundColor(.white)
//                        }
//                        .frame(width: 300)
                        
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(viewModel.categories) { category in
                                    NavigationLink(destination: MusicListView(viewModel: viewModel, showMusicCategoryView: $showMusicCategoryView, showToast: $showToast, audioFileURL: $audioFileURL,selectedTab: $selectedTab)) {
                                        ZStack {
                                            if let url = URL(string: category.cover ?? "") {
                                                WebImage(url: url)
                                                    .onSuccess { image, data, cacheType in
                                                        
                                                    }
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: (geo.size.width / 2) - 22, height: 250)
                                                    .clipped()
                                                    .cornerRadius(10)
                                            }else{
                                                
                                            }
                                            
                                            VStack {
                                                Spacer()
                                                Text(category.name ?? "")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .padding()
                                            }
                                        }
                                        .background(Color.clear)
                                        .cornerRadius(10)
                                    }
                                    .simultaneousGesture(
                                        TapGesture()
                                            .onEnded {
                                                viewModel.selectCategory(category)
                                            }
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .padding()
        }
        //}
    }
}


//#Preview {
//    MusicCategoryView(showMusicCategoryView: .constant(false), showToast: .constant(false))
//}
