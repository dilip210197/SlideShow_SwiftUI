//
//  ToastView.swift
//  SlideShow
//
//  Created by Shahrukh on 21/06/2024.
//

import SwiftUI

struct ToastPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}


struct ToastView: View {

    var body: some View {
        Text("Music is added successfully.")
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            .padding(.horizontal, 40)
    }
}
#Preview {
    ToastView()
}


struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                VStack {
                    Spacer().frame(height: 20)
                    Text("Music is added successfully!")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("primaryColor"))
                        .cornerRadius(10)
                        .padding(.horizontal, 50)
                    Spacer()
                   
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: isShowing)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing))
    }
}

