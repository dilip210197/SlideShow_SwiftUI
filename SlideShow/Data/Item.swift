//
//  Item.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
