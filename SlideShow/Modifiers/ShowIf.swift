//
//  ShowIf.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/21/24.
//

import SwiftUI

fileprivate struct ShowIf: ViewModifier {
    var condition: Bool
    
    func body(content: Content) -> some View {
        if condition {
            content
        }
    }
}

extension View {
    func showIf(_ condition: Bool) -> some View {
        self.modifier(ShowIf(condition: condition))
    }
}

