//
//  SelectMediaView.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/19/24.
//

import SwiftUI
import Photos

struct SelectMediaView: View {
    @EnvironmentObject var subscriptionModel: SubscriptionsViewModel
    @StateObject private var dataModel = PhotoLibraryViewModel.shared
    @State var showSubView = false
    @State var showSelectedMedia = false
    @State var selectedMedias = [PHAsset]()
    @State var selectedIdx = [Int]()

    let columns = [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)]

    let itemSize = (UIScreen.main.bounds.size.width - 6 - 4) / 3  // Adjusted for 1 point padding on all sides + 2 points spacing

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
//                        if dataModel.images.isEmpty {
//                            ProgressView()
//                                .scaleEffect(2.0)
//                                .foregroundColor(.accent)
//                                .frame(width: geometry.size.width, height: geometry.size.height)
//                        }
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(Array(dataModel.images.enumerated()), id: \.1) { idx, image in
                                Button {
                                    if selectedMedias.contains(image) {
                                        if let index = selectedMedias.firstIndex(where: { $0 == image}) {
                                            selectedMedias.remove(at: index)
                                        }
                                        if let index = selectedIdx.firstIndex(where: { $0 == idx}) {
                                            selectedIdx.remove(at: index)
                                        }
                                    } else {
                                        //NOTE - do we have a cap for subscribed users?
                                        if selectedMedias.count > 5 && !subscriptionModel.isSubscribed {
                                            showSubView = true
                                        } else {
                                            selectedMedias.append(image)
                                            selectedIdx.append(idx)
                                        }
                                    }
                                } label: {
                                    GridMediaView(size: itemSize, asset: image, idx: idx, selectedIdx: $selectedIdx)
                                        .padding([.all],1)  // Add 1 point padding around each item
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                        .onChange(of: selectedMedias) {
                            withAnimation {
                                showSelectedMedia = !selectedMedias.isEmpty
                            }
                        }
                    }
                }
                .background (
                    LinearGradient(gradient: Gradient(colors: [.black.opacity(0.7), .black]), startPoint: .top, endPoint: .bottom)
                )
                .toolbarRole(.editor)
                .toolbarBackground(.black, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Select media")
                            .font(.system(size: 20))
                            .bold()
                            .foregroundStyle(.white)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            NewProjectView(assets: selectedMedias)
                        } label: {
                            Text("Next")
                                .bold()
                                .frame(width: 80, height: 40)
                                .background(.accent)
                                .cornerRadius(10)
                                .foregroundStyle(.black)
                        }
                    }
                }
                .overlay {
                    SelectedMediaSheet(size: geometry.size.width * 0.18, selectedMedias: $selectedMedias, selectedIdx: $selectedIdx)
                        .background(Color.accentColor)
                        .frame(width: geometry.size.width, height: 200)
                        .cornerRadius(20)
                        .offset(y: showSelectedMedia ? geometry.size.height * 0.45 : geometry.size.height * 0.8)
                }
                .fullScreenCover(isPresented: $showSubView) { PurchaseView(isSheet: true) }
            }
        }
    }
}

