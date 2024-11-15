//
//  SelectedImageView.swift
//  SlideShow
//
//  Created by Shahrukh on 22/06/2024.
//
import SwiftUI

//struct SelectedImageView: View {
    
//    @EnvironmentObject var imageProject: ImageProject
//    @Binding var image: UIImage
//    @Binding var selectedIndex: Int
//    @Binding var showSelectMediaView: Bool
//    
//    @State private var draggingIndex: Int?
//    @State private var draggedOverIndex: Int?
//    @State private var isDragging: Bool = false
//    @State private var isOverTrashcan: Bool = false
//    @StateObject var viewModel = ThemeViewModel.shared
//    
//    var body: some View {
//        ZStack {
//            Color.black
//                .edgesIgnoringSafeArea(.all)
//            VStack(alignment: .center) {
//                Text("Hold and drag an image to reorder or delete")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                ScrollView(.horizontal, showsIndicators: false) {
//                        
//                        
//                        LazyHStack {
//                            // Extra item at the start
//                            VStack {
//                                VStack {
//                                    Spacer()
//                                    Image("SmallAdd")
//                                    Spacer()
//                                }
//                                .frame(width: 70, height: 70)
//                                .background(Color.gray)
//                                .cornerRadius(10)
//                            }
//                            .onTapGesture {
//                                showSelectMediaView.toggle()
//                            }
//                            
//                            // Existing images
//                            ForEach(imageProject.project.image.indices, id: \.self) { index in
//                                VStack {
//                                    Image(uiImage: UIImage(data: imageProject.project.image[index])!)
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 70, height: 120)
//                                        .cornerRadius(10)
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .stroke(selectedIndex == index ? Color.blue : Color.clear, lineWidth: 2)
//                                        )
//                                        .onDrag {
//                                            isDragging = true
//                                            draggingIndex = index
//                                            return NSItemProvider(object: "\(index)" as NSString)
//                                        }
//                                        .onDrop(of: ["Public.text"], delegate: dropDelegate(images: $imageProject.project.image, isDragging: $isDragging, isOverTrashcan: $isOverTrashcan, currentIndex: index))
//                                        .onTapGesture {
//                                            isDragging = false
//                                            selectedIndex = index
//                                            if let img = UIImage(data: imageProject.project.image[index]){
//                                                image = img
//                                            }
//                                        }
//                                }
//                                .frame(width: 80, height: 120)
////                                .opacity(draggingIndex == index ? 0.5 : 1.0) // Change opacity when dragging
//                            }
//                        }
//                        .frame(height: 150)
//                        .padding()
//                        
//                }
//                .frame(maxWidth: .infinity)
//                // Trashcan icon
//                HStack(alignment: .center){
//                    if isDragging {
//                        Spacer()
//                        Image(systemName: "trash")
//                            .resizable()
//                            .frame(width: isOverTrashcan ? 50 : 30, height: isOverTrashcan ? 50 : 30)
//                            .foregroundColor(isOverTrashcan ? .red : Color.accentColor)
//                            .onDrop(of: ["public.text"], delegate: TrashcanDropDelegate(images: $imageProject.project.image, draggingIndex: $draggingIndex, isOverTrashcan: $isOverTrashcan, isDragging: $isDragging))
//                            .animation(.easeInOut, value: isOverTrashcan)
//                        Spacer()
//                    }
//                }
//            }.frame(maxHeight: .infinity)
//                .onChange(of: isOverTrashcan) { newValue in
//                    if newValue {
//                        let generator = UIImpactFeedbackGenerator(style: .heavy)
//                        generator.impactOccurred()
//                    }
//                    
//                }
//        }
//    }
//}


//#Preview {
//    SelectedImageView()
//}
