//
//  ShareViewModel.swift
//  SlideShow
//
//  Created by Shahrukh on 20/06/2024.
//

import Foundation


struct FrameRate: Identifiable {
    let id = UUID()
    let rate: String?
}

class ShareViewModel: ObservableObject {
    
    @Published var selectedFrameRate: String = "24"
    var frames = ["24", "25", "30", "50", "60"]
    init() {
        selectedFrameRate = frames.first ?? ""
    }
    
}
