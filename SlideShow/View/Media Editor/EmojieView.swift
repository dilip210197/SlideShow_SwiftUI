//
//  ContentView.swift
//  SlideShow
//
//  Created by Work on 07/06/2024.
//

import SwiftUI

#Preview {
    EmojiCategoryView(selecteEmoji: .constant("f1"), showEmojieCategoryView: .constant(false), showEmojieView: .constant(false))
}

struct SelectedEmojiePreferenceKey: PreferenceKey {
    static var defaultValue: String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

struct EmojiCategoryView: View {
    private let categories: [EmojiCategory] = MockData.emojis
    @Binding var selecteEmoji: String
    @Binding var showEmojieCategoryView: Bool
    @Binding var showEmojieView: Bool
    @State private var selectedCategoryIndex: Int = 0
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    

    var body: some View {
        VStack {
            // Horizontal list of categories
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(categories.indices, id: \.self) { index in
                        
                        Image(categories[index].name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .onTapGesture {
                                selectedCategoryIndex = index
                                
                            }
                    }
                }
                .padding()
            }
            .frame(height: UIScreen.main.bounds.height * 0.1)
            
            // Display emojis for the selected category in a LazyVGrid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(categories[selectedCategoryIndex].emojis, id: \.self) { emoji in
                        
                        Image(emoji)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .onTapGesture {
                                selecteEmoji = emoji
                                showEmojieCategoryView = false
                                showEmojieView = true
                            }
                    }
                }
                .padding()
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.08),Color.white.opacity(0)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct EmojiCategory {
    let name: String
    let emojis: [String]
}

struct MockData {
    static var emojis: [EmojiCategory] = [
        EmojiCategory(name: "f1", emojis: ["f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12", "f13", "f14", "f15", "f16", "f17", "f18"]),
            
            EmojiCategory(name: "c1", emojis: ["c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "c10", "c11", "c12", "c13", "c14", "c15"]),
            
            EmojiCategory(name: "l1", emojis: ["l1", "l2", "l3", "l4", "l5", "l6", "l7", "l8", "l9", "l10", "l11", "l12", "l13", "l14", "l15", "l16", "l17", "l18", "l19", "l20", "l21", "l22", "l23", "l24", "l25", "l26", "l27", "l28","l29","l30"]),
            
            EmojiCategory(name: "b0", emojis: ["b0", "b2", "b3", "b4", "b5", "b6", "b7", "b8", "b9", "b10", "b11", "b12", "b13", "b14", "b15", "b16", "b17", "b18", "b19", "b20", "b21", "b22", "b23", "b24"]),
            
            EmojiCategory(name: "h1", emojis: ["h1", "h2", "h3", "h4", "h5", "h6", "h7", "h8", "h9", "h10", "h11", "h12", "h13", "h14", "h15"]),
            
            EmojiCategory(name: "d1", emojis: ["d1", "d2", "d3", "d4", "d5", "d6", "d7", "d8", "d9", "d10", "h11", "h12", "h13", "h14", "h15"])
        ]
}
