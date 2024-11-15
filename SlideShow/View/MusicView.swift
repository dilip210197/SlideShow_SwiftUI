//
//  MusicView.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import SwiftUI

struct MusicView: View {

    @State var showMusicCategoryView: Bool = false
    @Binding var showToast: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack {
                BigButton(action: {
                    showMusicCategoryView.toggle()
                }, image:  "ButtonRotate")
                .fullScreenCover(isPresented: $showMusicCategoryView, content: {
                    //MusicCategoryView(showMusicCategoryView: $showMusicCategoryView, showToast: $showToast)
                })
                
                Text("Music")
                    .foregroundColor(.white)
                
            }
        }
        
    }
}

//#Preview {
//    MusicView(showToast: .constant(false))
//}
