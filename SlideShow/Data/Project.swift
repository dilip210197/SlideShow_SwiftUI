//
//  Project.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/18/24.
//

import SwiftUI
import SwiftData

@Model
final class Project {
    var id = UUID()
    var name: String
    var image: [Data]
    var ratio: Ratio
    var dateCreated: Date
    var imageTimer: Double
    var selectedTheme: String
    
    init(name: String, image: [Data], ratio: Ratio, dateCreated: Date, timer:Double,selectedTheme:String) {
        self.name = name
        self.image = image
        self.ratio = ratio
        self.dateCreated = dateCreated
        self.imageTimer = timer
        self.selectedTheme = selectedTheme
    }
    
    func aspectRatio() -> CGFloat {
        switch ratio {
        case .standard:
            return 4.0 / 3.0
        case .portrait:
            return 9.0 / 16.0
        case .landscape:
            return 16.0 / 9.0
        case .square:
            return 1.0
        }
    }
}

enum Ratio: Int, Codable {
    case standard
    case portrait
    case landscape
    case square
}
