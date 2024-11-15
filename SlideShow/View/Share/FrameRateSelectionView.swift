//
//  FrameRateView.swift
//  SlideShow
//
//  Created by Shahrukh on 20/06/2024.
//

import SwiftUI

struct FrameRateSelectionView: View {
    @Binding var selectedFrameRate: Int
    @Binding var isShowFrameRate: Bool
    let frameRates = [24, 25, 30, 50, 60]
    
    var body: some View {
        VStack {
            Text("Frame Rate")
                .font(.headline)
                .padding(.bottom, 5)
            
            Text("The more frames per second in your video, the more fluid it will be")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 10) {
                ForEach(frameRates, id: \.self) { frameRate in
                    Button(action: {
                        selectedFrameRate = frameRate
                        isShowFrameRate.toggle()
                    }) {
                        VStack {
                            Text("\(frameRate)")
                                .bold()
                                
                                .foregroundColor(selectedFrameRate == frameRate ? Color.white : Color.black)
                                
                            Text("FPS")
                                .font(.caption2)
                                .foregroundColor(selectedFrameRate == frameRate ? Color.white : Color.black)
                            
                        }
                        .padding()
                        .background(selectedFrameRate == frameRate ? Color.black : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("primaryColor"), lineWidth: 1)
                        )
                        .cornerRadius(10)
                        
                    }
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color(hex: "#74C0CD"))
        .cornerRadius(30)
        .padding()
    }
}

#Preview {
    FrameRateSelectionView(selectedFrameRate: .constant(25), isShowFrameRate: .constant(false))
}

