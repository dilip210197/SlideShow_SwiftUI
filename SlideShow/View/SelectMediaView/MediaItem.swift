//
//  Item.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/19/24.
//

import SwiftUI

struct ImageItem: Identifiable {
    let id = UUID()
    let url: URL
}

extension ImageItem: Equatable {
    static func ==(lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
}
