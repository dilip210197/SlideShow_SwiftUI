//
//  TopEditButtonsView.swift
//  SlideShow
//
//  Created by Shahrukh on 06/06/2024.
//

import SwiftUI

struct AddEmojiePreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}



struct TopEditButtonsView: View {
    
    enum SelectedState {
        case add
        case trim
//        case time
        case rotate
        case volume
    }
    
    //    @ObservedObject var settings: MediaEditingViewModel
    @Binding var selected: SelectedState
    //    @State var showEmojieCategoryView: Bool = false
    //    @Binding var showEmojieView: Bool
    //    @Binding var selectedEmojie: String?
    //    @Binding var rotationAngle: Angle
    //    @Binding var showDraggable: Bool
    //    @Binding var showToast: Bool
    
    //    var onDoneTextWaterMark: () -> Void
    //    var onDoneEmojieWaterMark: () -> Void // Define a cl
    
    var body: some View {
        VStack() {
//            Image("BarEdit")
//                .resizable()
//                .frame(height: 40)
//                .scaledToFill()
            
            HStack {
                /*Spacer(minLength: 0)
                
                TopEditButtonStyle(isSelected: selected == .add, isEnabled: true,
                                   action: { selected = .add },
                                   selectedImage: "IconAddSelected",
                                   defaultImage: "IconAdd")
                
                Spacer(minLength: 0)
                
                TopEditButtonStyle(isSelected: selected == .trim, isEnabled: false,
                                   action: { selected = .trim },
                                   selectedImage: "IconTrimSelected",
                                   defaultImage: "IconTrim")*/
                
//                Spacer(minLength: 0)
//
//                TopEditButtonStyle(isSelected: selected == .time,
//                                   action: { selected = .time },
//                                   selectedImage: "IconTimeSelected",
//                                   defaultImage: "IconTime")
                
                Spacer(minLength: 0)
                
                TopEditButtonStyle(isSelected: selected == .rotate, isEnabled: true,
                                   action: { selected = .rotate },
                                   selectedImage: "IconSizeSelected",
                                   defaultImage: "IconSize")
                
                Spacer(minLength: 0)
                
                /*TopEditButtonStyle(isSelected: selected == .volume, isEnabled: false,
                                   action: { selected = .volume },
                                   selectedImage: "IconMusicSelected",
                                   defaultImage: "IconMusic")
                
                Spacer(minLength: 0)*/
            }
            .padding(.horizontal, 10)
            .padding(.top, 40)
        }
        
        .edgesIgnoringSafeArea(.top)

    }
}
//        GeometryReader { geometry in
//            ZStack {
//
//
//
//                    switch selected {
//                    case .add:
//
//                        EditFeatureView(settings: settings,
//                                        showDraggableTextView: $showDraggable,
//                                        showEmojieCategoryView: $showEmojieCategoryView,
//                                        selected: .punchItem,
//                                        rotationAngle: $rotationAngle,
//                                        showToast: $showToast)
//
//
//
//                    case .trim,  .rotate :
//                        EditFeatureView(settings: settings,
//                                        showDraggableTextView: $showDraggable,
//                                        showEmojieCategoryView: $showEmojieCategoryView,
//                                        selected: .rotateFlip,
//                                        rotationAngle: $rotationAngle,
//                                        showToast: $showToast)
//
//
//                    case .time:
//                        DurationView()
//
//
//                    case .volume:
//                        DurationView(title: "Volume")
//
//                    }
//
//
//
//                    BigButton(action: {
//                        if (showDraggable) {
//                            onDoneTextWaterMark()
//                        }
//                        if showEmojieView {
//                            onDoneEmojieWaterMark()
//                        }
//
//                    }, image: selected == .add ? "ButtonDone" : "ButtonDoneCheck")

//                }
//                .frame(maxWidth: .infinity)
//                .background(Color.clear)

//                if showEmojieCategoryView {
//
//                    EmojiCategoryView(selecteEmoji: $selectedEmojie, showEmojieCategoryView: $showEmojieCategoryView, showEmojieView: $showEmojieView)
//
//
//                }
//            }
//        }
//    }
//}

//#Preview {
//    TopEditButtonsView(settings: MediaEditingViewModel(), showEmojieView: .constant(false), selectedEmojie: .constant(""), rotationAngle: .constant(Angle(degrees: 0)), showDraggable: .constant(false), {
//    }, {
//    })
//}

struct TopEditButtonStyle: View {
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void
    let selectedImage: String
    let defaultImage: String
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            Image(isSelected ? selectedImage : defaultImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 45, height: 45)
                .opacity(isEnabled ? 1.0 : 0.5) // Change opacity based on isEnabled
        }
        .overlay(
            Circle()
                .stroke(isSelected ? Color("primaryColor") : Color.clear, lineWidth: 2)
                .frame(width: 50, height: 50)
        )
        .disabled(!isEnabled) // Disable the button if isEnabled is false
    }
}


struct BigButton: View {
    let action: () -> Void
    let image: String
    
    var body: some View {
        Button(action: action) {
            Image(image)
        }
    }
}

#Preview {
    VStack {
        Color.white
        TopEditButtonsView(selected: .constant(.add))
    }
    .background(.black)
}
