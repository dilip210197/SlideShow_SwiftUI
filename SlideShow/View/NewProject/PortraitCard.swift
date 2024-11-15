//
//  PortraitCard.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/12/24.
//

import SwiftUI

struct PortraitCard: View {
    let ratio: String
    let description: String
    let index: Int
    @Binding var selectedIndex: Int?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: selectedIndex == index ? "largecircle.fill.circle" : "circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor((isSelected() ? .accent : .white))
                .onTapGesture { selectedIndex = index }
            
            Spacer()
                .frame(height: 20)
            
            Text(ratio)
                .font(.body)
                .bold()
                .foregroundColor(.white)
            
            Text(description)
                .font(.body)
                .foregroundColor(.gray)
        }
    }
    
    func isSelected() -> Bool { return selectedIndex == index }
}

struct PortraitCardGroup<Content: View>: View {
    let content: Content
    @Binding var selectedIndex: Int?

    init(selectedIndex: Binding<Int?>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._selectedIndex = selectedIndex
    }

    var body: some View {
        content
    }
}

#Preview {
    @State var selected: Int? = 1
    return PortraitCard(ratio: "4:3", description: "Standard", index: 1, selectedIndex: $selected)
}

