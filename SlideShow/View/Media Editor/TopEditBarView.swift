//
//  TopEditBar.swift
//  SlideShow
//
//  Created by Shahrukh on 06/06/2024.
//

import SwiftUI

struct TopEditBarView: View {
    @Binding var showEditButton: Bool
    @Binding var showEmojieView: Bool
    @Binding var showTextView: Bool
    @Binding var showShareView: Bool

    var body: some View {
        VStack {
            HStack {
                // Back Button
                Button(action: {
                    print("Back button pressed")
                }) {
                    Image("IconBack")
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()

                // Center Buttons (Undo and Redo)
                HStack(spacing: 20) {
                    Button(action: {
                        print("Undo button pressed")
                    }) {
                        Image("IconUndo")
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Button(action: {
                        print("Redo button pressed")
                    }) {
                        Image("IconRedo")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                Spacer()

                // Done Button
                if !showEditButton {
                    Button(action: {
                        showEditButton.toggle()
                    }) {
                        Text("Done")
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color("primaryColor"))
                            .bold()
                            .cornerRadius(3.0)
                    }
                    .padding()
                } else {
                    // Add an invisible button to keep space
                    Button(action: {
                        showShareView.toggle()
                    }) {
                        Image("IconShare")
                            .resizable()
                            .frame(width: 35, height: 35)
                            
                    }
                    .fullScreenCover(isPresented: $showShareView) {
                       // ShareView(showShareView: $showShareView)
                    }
                    .padding()
                }
                
                
            }
        }
    }
}
