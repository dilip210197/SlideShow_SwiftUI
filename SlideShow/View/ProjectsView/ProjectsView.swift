//
//  ProjectsView.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.modelContext) var context
    @StateObject private var viewModel = ProjectsViewModel()
    @State var showOnBoard = UserDefaults.standard.bool(forKey: Keys.showOnBoarding)
    @State var showEditView = false
    @State var showRenameView = false
    @State var loadingImages = false
    @State var idxToEdit = 0
    @Query(sort: \Project.dateCreated) var projects: [Project] = []
    
    var body: some View {
  //      GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    ScrollView {
                        ProjectList(showRenameView: $showRenameView,
                                    showEditView: $showEditView,
                                    idxToEdit: $idxToEdit,
                                    projects: projects)
                    }
                    .padding(.top, 30)
                    
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Projects")
                                .foregroundStyle(.white)
                                .font(.title)
                                .bold()
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                PurchaseView(isSheet: false)
                            } label: {
                                //                            Image(systemName: "exclamationmark.circle.fill")
                                Image(systemName: "star.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        ToolbarItem(placement: .bottomBar) {
                            Button {
                                Task { @MainActor in
                                    loadingImages = true
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .padding(.bottom, 20)
                            }
                        }
                    }
                    .toolbarBackground(.clear, for: .bottomBar)
                    .background (
                        LinearGradient(gradient: Gradient(colors: [.black.opacity(0.7), .black]), startPoint: .top, endPoint: .bottom)
                    )
                    .sheet(isPresented: $showEditView) {
                        EditView(showEditView: $showEditView,
                                 showRenameView: $showRenameView,
                                 idxToEdit: $idxToEdit,
                                 projects: projects)
                        .presentationDetents([.height(UIScreen.main.bounds.height * 0.35)])
                    }
                    .fullScreenCover(isPresented: $showOnBoard) { OnBoardingView() }
                    .navigationDestination(isPresented: $loadingImages) { SelectMediaView() }
                    
                    ProgressView()
                        .showIf(loadingImages)
                }
            }
    //    }
    }
}

#Preview {
    ProjectsView()
}
