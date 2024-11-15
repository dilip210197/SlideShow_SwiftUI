//
//  ThemeSelectionView.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import SwiftUI
import AVFoundation
import PhotosUI
import AVKit
import ImageIO
import SDWebImageSwiftUI

struct ThemeSelectionView: View {
    @State private var items = [
        ("Love_Theme", "Love"),
        ("Anniversary_Theme", "Anniversary"),
        ("Birthday_Theme", "Birthday"),
        ("Celebration_Theme", "Celebration"),
      //  ("Vintage_Theme", "Vintage"),
        ("Memories_Theme", "Memories"),
        ("Christmas_Theme", "Christmas"),
        ("Calm_Theme", "Calm"),
    ]
    
    let columns: [GridItem] = [
        GridItem(.flexible())
    ]
    @State private var selectedImages: [UIImage?] = []
    @Binding private var selectedItem: String? 
    @StateObject var viewModel = ThemeViewModel.shared
    @State private var frameSize: CGSize = .zero
    init(selectedItem: Binding<String?>, items: [(String, String)]) {
        _selectedItem = selectedItem
        self.items = items
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: columns, spacing: 3) {
                ForEach(items, id: \.0) { item in
                    Spacer()
                    VStack {
                        
                        if self.viewModel.selectedAspectRatio == .portrait {
                            let url = Bundle.main.url(forResource: "\(item.0)", withExtension: "gif")!
                            let data = try! Data(contentsOf: url)
                            AnimatedImage(data: data)
                                .resizable()
                                .indicator(.activity) // Activity Indicator while loading
                                .scaledToFill()
                                .frame(width: 65, height: 125, alignment: .center)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedItem == item.1 ? Color.white : Color.clear, lineWidth: 2)
                                )
                        } else if self.viewModel.selectedAspectRatio == .landscape {
                            let url = Bundle.main.url(forResource: "\(item.0)_Landscape", withExtension: "gif")!
                            let data = try! Data(contentsOf: url)
                            AnimatedImage(data: data)
                                .resizable()
                                .indicator(.activity) // Activity Indicator while loading
                                .scaledToFill()
                                .frame(width: 125, height: 65, alignment: .center)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedItem == item.1 ? Color.white : Color.clear, lineWidth: 2)
                                )
                        } else if self.viewModel.selectedAspectRatio == .square {
                            let url = Bundle.main.url(forResource: "\(item.0)_Square", withExtension: "gif")!
                            let data = try! Data(contentsOf: url)
                            AnimatedImage(data: data)
                                .resizable()
                                .indicator(.activity) // Activity Indicator while loading
                                .scaledToFill()
                                .frame(width: 125, height: 125, alignment: .center)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedItem == item.1 ? Color.white : Color.clear, lineWidth: 2)
                                )
                        } else if self.viewModel.selectedAspectRatio == .standard {
                            let url = Bundle.main.url(forResource: "\(item.0)_Standard", withExtension: "gif")!
                            let data = try! Data(contentsOf: url)
                            AnimatedImage(data: data)
                                .resizable()
                                .indicator(.activity) // Activity Indicator while loading
                                .scaledToFill()
                                .frame(width: 125, height: 105, alignment: .center)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedItem == item.1 ? Color.white : Color.clear, lineWidth: 2)
                                )
                        }
                      
                        
                        Text(item.1)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .onTapGesture {
                        selectedItem = item.1
                    }
                }
            }
            .padding()
        }.scrollIndicators(.hidden)
            .onAppear {
                // Ensure default selection is set if `selectedItem` is nil
                if selectedItem == nil {
                    selectedItem = items.first?.1
                }
                self.frameSize = makeSizeSmaller(originalSize: viewModel.setting.size, by: 3.0)
            }
    }
    
    // Method to make CGSize smaller by a factor
    func makeSizeSmaller(originalSize: CGSize, by factor: CGFloat) -> CGSize {
        return CGSize(width: originalSize.width / factor, height: originalSize.height / factor)
    }
}
