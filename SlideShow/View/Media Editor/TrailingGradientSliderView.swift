//
//  TrailingGradientSliderView.swift
//  SlideShow
//
//  Created by Shahrukh on 09/06/2024.
//

import SwiftUI

struct TrailingGradientSliderView: View {
    @State private var sliderValue: Double = 0.0
    
    var body: some View {
        VStack {
            
            
            ZStack(alignment: .leading) {
                if sliderValue > 0 {
                    trailingGradientView()
                        .frame(width: (CGFloat(sliderValue) * UIScreen.main.bounds.width) + (45 - sliderValue * 65.0), height: 30)
                        .animation(.easeInOut)
                }
                
                Slider(value: $sliderValue, in: 0...1)
                    .padding(.horizontal)
                    .accentColor(.blue)
                    .tint(Color("primaryColor"))
            }
        }
    }
    
    private func trailingGradientView() -> some View {
        LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0), Color("primaryColor").opacity(0.5)]), startPoint: .leading, endPoint: .trailing)
               .mask(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

#Preview {
    TrailingGradientSliderView()
}
