//
//  OnBoardingView.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/8/24.
//

import SwiftUI

struct OnBoardingView: View {
    @StateObject var permissions = DevicePermissions()
    @State var currentSlide = 0
    @State var showingAlert = false
    @State var initialLoad = true
    
    var list = [
        OnBoardingSlide(image: "Onboarding01",
                        title: "Hi!",
                        detail: "Let's make a slideshow",
                        footer: "By continuing, you accept our Terms of Service and acknowledge receipt of our privacy policy."),
        
        OnBoardingSlide(image: "Onboarding02",
                        title: "",
                        detail: "We'll need access to your photo library",
                        footer: "Allow use of photo library"),
        
        OnBoardingSlide(image: "Onboarding03",
                        title: "",
                        detail: "Play with our effect to make it just right",
                        footer: ""),
        
        OnBoardingSlide(image: "Onboarding04",
                        title: "",
                        detail: "Add magic with the perfect soundtrack",
                        footer: ""),
        
        OnBoardingSlide(image: "Onboarding05",
                        title: "",
                        detail: "Thats it! Powerful editing made simple",
                        footer: ""),
        
        OnBoardingSlide(image: "Onboarding06",
                        title: "",
                        detail: "Create your first slideshow",
                        footer: "")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader{ proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(Array(list.enumerated()), id: \.0) { idx, slide in
                            OnBoardingSlideView(permissions: permissions,
                                                image: slide.image,
                                                title: slide.title,
                                                detail: slide.detail,
                                                footer: slide.footer,
                                                slide: idx,
                                                showingAlert: $showingAlert,
                                                currentSlide: $currentSlide)
                            .frame(width: geometry.size.width)
                            .onAppear {
                                if initialLoad {
                                    initialLoad = false
                                    return
                                }
                                
                                if idx  >= 1 {
                                    if !permissions.isGalleryPermissionGranted {
                                        Task { @MainActor in
                                            await permissions.requestGalleryPermission()
                                            showingAlert = permissions.isShowingAlert
                                        }
                                    }
                                }
                                
                                currentSlide = min(idx, currentSlide)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .padding(.top, 30)
                .background (
                    LinearGradient(gradient: Gradient(colors: [.black.opacity(0.7), .black]), startPoint: .top, endPoint: .bottom)
                )
                .scrollTargetBehavior(.viewAligned)
                .defaultScrollAnchor(.leading)
                .onChange(of: currentSlide) {
                    withAnimation { proxy.scrollTo(currentSlide) }
                }
                .alert("You must agree to photo permissions continue", isPresented: $showingAlert) { Button("OK") { } }
            }
        }
    }
}

#Preview {
    OnBoardingView()
}
