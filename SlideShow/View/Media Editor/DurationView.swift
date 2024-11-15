//
//  DurationView.swift
//  SlideShow
//
//  Created by Shahrukh on 10/06/2024.
//

import SwiftUI

struct DurationView: View {
    
    @State var title: String = "Duration"
    
    var body: some View {
        
        VStack {
            HStack {
                Text(title).foregroundColor(.white)
                    .font(.title3).bold()
                Spacer()
                Text("3s").foregroundColor(.white)
            }
            
            TrailingGradientSliderView()
            
            HStack {
                Text("0.1s").foregroundColor(.white)
                Spacer()
                Text("10s").foregroundColor(.white)
            }
        }
        
    }
}

#Preview {
    DurationView()
}
