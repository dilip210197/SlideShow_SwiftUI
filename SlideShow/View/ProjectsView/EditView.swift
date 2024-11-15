//
//  EditView.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/12/24.
//

import SwiftUI

struct EditView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    @Binding var showEditView: Bool
    @Binding var showRenameView: Bool
    @Binding var idxToEdit: Int
    var projects: [Project]
    var items = [ "Rename", "Delete", "Close" ]
    
    var body: some View {
        VStack {
            List {
                ForEach(Array(items.enumerated()), id: \.1) { idx, item in
                    Button {
                        switch idx {
                        case 0:
                            Task { @MainActor in
                                showEditView = false
                                try await Task.sleep(nanoseconds: 200_000)
                                showRenameView = true
                            }
                        case 1:
                            Task { @MainActor in
                                context.delete(projects[idxToEdit])
                                dismiss()
                            }
                        case 2:
                            dismiss()
                        default:
                            break
                        }
                    } label: {
                        Text(item)
                            .foregroundStyle(idx == 1 ? .black : .white)
                            .bold()
                            .frame(height: 50)
                    }
                    .listRowBackground(Color.accentColor.opacity(0.5))
                    .listRowSeparatorTint(idx == 1 ? Color.accentColor : .clear)
                }
            }
            .scrollDisabled(true)
        }
        .scrollContentBackground(.hidden)
        .background (
            LinearGradient(gradient: Gradient(colors: [.black.opacity(0.91), .black]), startPoint: .top, endPoint: .bottom)
        )
    }
}
