//
//  NameProjectView.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/12/24.
//

import SwiftUI

struct RenameProjectView: View {
    var project: Project
    var idxToEdit: Int
    @State var projectName: String
    @State private var becomeFirstResponder = true
    @Binding var showingRenameView: Bool
    @Binding var showEditView: Bool
    @Environment(\.modelContext) var context
    
    var body: some View {
        GeometryReader { geomtry in
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: geomtry.size.height / 2)
                    
                    NameProjectTextfield(projectName: $projectName, becomeFirstResponder: self.$becomeFirstResponder)
                        .onAppear {
                            withAnimation { self.becomeFirstResponder = true }
                        }
                }
            }
            .scrollDisabled(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task { @MainActor in
                            showEditView = false
                            showingRenameView = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { @MainActor in
                            project.name = projectName
                            try context.save()
                            showEditView = false
                            showingRenameView = false
                        }
                    } label: {
                        Text("Done")
                            .bold()
                            .frame(width: 80, height: 40)
                            .background(.accent)
                            .cornerRadius(10)
                            .foregroundStyle(.black)
                    }
                }
            }
            .background (
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.7), .black]), startPoint: .top, endPoint: .bottom)
            )
        }
    }
}
