//
//  AnimationStore.swift
//  SlideShow
//
//  Created by Anuj Joshi on 28/06/24.
//

import Foundation
import SwiftUI
import QuartzCore

class AnimationStore: ObservableObject {
    
    public static let shared = AnimationStore()

    @Published var animations: [CAKeyframeAnimation] = []

    func addAnimation(_ animation: CAKeyframeAnimation) {
        animations.append(animation)
    }

    func getAnimation(at index: Int) -> CAKeyframeAnimation? {
        guard index < animations.count else { return nil }
        return animations[index]
    }
}
