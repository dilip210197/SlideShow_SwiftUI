//
//  OnBoardingSlideView.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/8/24.
//

import SwiftUI
import Photos

struct OnBoardingSlide: Hashable {
    var image: String
    var title: String
    var detail: String
    var footer: String
}

struct OnBoardingSlideView: View {
    @ObservedObject var permissions: DevicePermissions
    var image: String
    var title: String
    var detail: String
    var footer: String
    var slide: Int
    @Binding var showingAlert: Bool
    @Binding var currentSlide: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            Image(image)
                .padding(.horizontal, 35)
            
            Spacer()
                .frame(height: 30)
            
            Text(title)
                .font(.system(size: 35, weight: .medium))
                .foregroundStyle(.white)
            
            Text(detail)
                .font(.system(size: 30, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            
            Spacer()
            
            Text(footer)
                .font(.system(size: 13, weight: .light))
                .frame(width: 300)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            
            Spacer()
                .frame(height: 5)
            
            Button {
                if slide == 1 {
                    if !permissions.isGalleryPermissionGranted {
                        Task {
                            if !permissions.isGalleryPermissionGranted {
                                await permissions.requestGalleryPermission()
                            }
                            showingAlert = permissions.isShowingAlert
                        }
                        return
                    }
                } else {
                    if slide == 5 {
                        UserDefaults.standard.setValue(false, forKey: Keys.showOnBoarding)
                        dismiss()
                    }
                }
                
                currentSlide = slide + 1
            } label: {
                Circle()
                    .frame(width: 50, height: 50)
                    .accentColor(Color(red: 0.0, green: 244, blue: 249))
                    .overlay {
                        Image(systemName: slide == 5 ? "plus" :  "arrow.right")
                            .tint(.black)
                    }
            }
        }
        .padding()
    }
}
