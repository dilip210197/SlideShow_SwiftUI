//
//  MediaItemDisplayView.swift
//  SlideShow
//
//  Created by Shahrukh on 06/06/2024.
//

import SwiftUI

struct MediaItemDisplayView: View {
    
    @StateObject var viewModel: MediaEditingViewModel = MediaEditingViewModel()
    
    @State var imageProject:ImageProject = ImageProject(project: Project(name: "", image: [], ratio: .landscape, dateCreated: Date(), timer: 0, selectedTheme: ""))
    
    @State var showEmojieView: Bool = false
    @State var initialOffset: CGSize = .zero
    @State private var rotationAngle: Angle = .zero
    
    @State private var isEditing = false
    @State private var previousScale: CGFloat = 1.0
    @State private var showingImagePicker = false
    
    @State var showShareView: Bool = false
    @State var showToast = false
    @Binding var showMusicView: Bool
    @State var showMusicCategoryView: Bool = false
    @State var showSelectMediaView: Bool = false
    
    @Binding var project:Project
    
    var setRatio:Ratio
    var setting = RenderSettings()
    @State var imageUpdate:Bool = false
    
    @State private var draggingIndex: Int?
    @State private var draggedOverIndex: Int?
    @State private var isDragging: Bool = false
    @State private var isOverTrashcan: Bool = false
    
    @State private var imageProjectData:[Data] = []
    
    @State var selectedTab: TopEditButtonsView.SelectedState = .rotate
    @StateObject var viewModels = ThemeViewModel.shared
    
    var mainView: some View {
        
        let newSize: CGSize
        var aspectRatio = 9.0 / 16.0
        
        if setRatio == .standard {
            aspectRatio = 4.0/3.0
        }else if setRatio == .portrait {
            aspectRatio = 9.0/16.0
        }else if setRatio == .landscape {
            aspectRatio = 16.0/9.0
        }else if setRatio == .square {
            aspectRatio = 1.0/1.0
        }
        
        if aspectRatio > 1 {
            newSize = CGSize(width: 800, height: 800 / aspectRatio)
        } else {
            newSize = CGSize(width: 800 * aspectRatio, height: 800)
        }
        
        let resizedImage = resizeImage(image: viewModel.mainImage, targetSize: newSize)
        return Image(uiImage: resizedImage)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let halfSize = CGSize(width: targetSize.width / 2, height: targetSize.height / 2)
        let size = image.size

        let widthRatio  = halfSize.width  / size.width
        let heightRatio = halfSize.height / size.height
        let scaleFactor = max(widthRatio, heightRatio) // Scale to fill

        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: halfSize)
        let scaledImage = renderer.image { context in
            let origin = CGPoint(x: (halfSize.width - scaledImageSize.width) / 2, y: (halfSize.height - scaledImageSize.height) / 2)
            image.draw(in: CGRect(origin: origin, size: scaledImageSize))
        }
        
        return scaledImage
    }

    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack {
                GeometryReader { geometry in
                    HStack(alignment: .center) {
                        VStack{
                            mainView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top)
                    .background(.black)
                    .overlay(
                        Group {
                            if viewModel.showingTextInputView && viewModel.isEditing {
                                
                                WaterMarkerLabel(settings: viewModel)
                            }
                        }
                    )
                    .overlay(
                        Group {
                            if viewModel.showingTextInputView && viewModel.isEditing {
                                HStack {
                                    ColorPicker("", selection: $viewModel.textOverlay.color)
                                    Button(action: {
                                        viewModel.textOverlay.hasBackground.toggle()
                                    }, label: {
                                        Image(systemName: viewModel.textOverlay.hasBackground ? "rectangle.slash.fill" : "rectangle.fill")
                                            .font(.system(size: viewModel.textOverlay.hasBackground ? 20 : 25))
                                            .foregroundStyle(Color.white)
                                    })
                                }
                                .padding()
                            }
                        }, alignment: .bottomLeading)
                    .overlay (
                        Group {
                            if showEmojieView && viewModel.emojiOverlay.emoji != "" {
                                ScalableView(settings: viewModel)
                                    .onAppear {
                                        viewModel.showingTextInputView = false
                                        viewModel.isEditingText = false
                                    }
                            }
                        }
                    )
                    .overlay(
                        // Show TextField when editing text
                        Group {
                            if viewModel.isEditingText && viewModel.showingTextInputView {
                                
                                KeyboardTextField(text: $viewModel.textOverlay.text, isEditing: $viewModel.isEditingText, placeholder: "Type here..")
                                    .padding()
                                    .multilineTextAlignment(.center) // Center align the text
                                
                                    .cornerRadius(5)
                                    .position(x: 0 , y: 0)
                                    .frame(height: 50)
                                    .onAppear {
                                        viewModel.showingEmojiInputView = false
                                        viewModel.emojiOverlay.emoji = ""
                                    }
                            }
                        }
                    )
                    .overlay(alignment: .bottomTrailing) {
                        Group {
                            if !viewModel.isEditing {
                                
                                BigButton(action: {
                                    viewModel.isEditing = true
                                    
                                }, image: "ButtonEdit")
                                .padding()
                            }
                        }
                    }
                }
                
                if (!viewModel.isEditing) {
                    //                SelectedImageView(image: $viewModel.mainImage, selectedIndex: $viewModel.index, showSelectMediaView: $showSelectMediaView,imageUpdated: $imageUpdate)
                    
                    ZStack{
                        VStack(alignment: .center) {
                            Text("Hold and drag an image to reorder or delete")
                                .font(.caption)
                                .foregroundColor(.gray)
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    
                                    VStack {
                                        VStack {
                                            Spacer()
                                            Image("SmallAdd")
                                            Spacer()
                                        }
                                        .frame(width: 70, height: 70)
                                        .background(Color.gray)
                                        .cornerRadius(10)
                                    }
                                    .onTapGesture {
                                        showSelectMediaView.toggle()
                                    }
                                    if (isDragging == false || isDragging == true){
                                        ForEach(imageProject.project.image.indices, id: \.self) { index in
                                            VStack {
                                                multiImageView(data: imageProject.project.image[index])
//                                                Image(uiImage: UIImage(data: )
//                                                    .resizable()
//                                                    .scaledToFill()
//                                                    .frame(width: 70, height: 120)
                                                    .cornerRadius(10)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(viewModel.index == index ? Color.blue : Color.clear, lineWidth: 2)
                                                    )
                                                    .onDrag {
                                                        isDragging = true
                                                        draggingIndex = index
                                                        return NSItemProvider(object: "\(index)" as NSString)
                                                    }
                                                    .onDrop(of: ["Public.text"], delegate: dropDelegate(isDragging: $isDragging, isOverTrashcan: $isOverTrashcan, currentIndex: index, imageProject: $imageProject))
                                               
                                                    .onTapGesture {
                                                        isDragging = false
                                                        viewModel.index = index
                                                        applyMainImage()
                                                        self.imageUpdate = true
                                                    }
                                            }
                                            .frame(height: 120)
                                        }
                                        .frame(height: 150)
                                        //                                    .padding()
                                    }
                                }
                                
                            }.frame(maxWidth: .infinity)
                            // Trashcan icon
                            if isDragging {
                                
                                HStack(alignment: .center){
                                    Spacer()
                                    Image(systemName: "trash")
                                        .resizable()
                                        .frame(width: isOverTrashcan ? 50 : 30, height: isOverTrashcan ? 50 : 30)
                                        .foregroundColor(isOverTrashcan ? .red : Color.accentColor)
                                        .onDrop(of: ["public.text"], delegate: TrashcanDropDelegate(draggingIndex: $draggingIndex, isOverTrashcan: $isOverTrashcan, isDragging: $isDragging, imageProject: $imageProject))
                                    //                                    .onDrop(of: ["public.text"], delegate: TrashcanDropDelegate(imageProject: $imageProject, draggingIndex: $draggingIndex, isOverTrashcan: $isOverTrashcan, isDragging: $isDragging))
                                        .animation(.easeInOut, value: isOverTrashcan)
                                    Spacer()
                                }.frame(maxHeight: .infinity)
                                    .onChange(of: isOverTrashcan) { newValue in
                                        if newValue {
                                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                                            generator.impactOccurred()
                                        }
                                        
                                    }
                            }
                            
                        }.frame(height: 260)
                    }
                    
                    
                } else {
                    
                    if !viewModel.isEditingText {
                        if viewModel.showingEmojiInputView {
                            EmojiCategoryView(selecteEmoji: $viewModel.emojiOverlay.emoji, showEmojieCategoryView: $viewModel.showingEmojiInputView, showEmojieView: $showEmojieView)
                        } else {
//                            MediaEditorView(settings: viewModel, imageProject: $imageProject, isEditing: $viewModel.isEditing)
                            
                            
                            // code start
                            
                            
                            VStack {
//                                TopEditButtonsView(selected: $selectedTab)
//                                
//                                //MARK: - Tab specific edit buttons
//                                VStack {
//                                    switch selectedTab {
//                                    case .add:
//                                        HStack {
//                                            BigButton(action: {
//                                                viewModel.showingTextInputView.toggle()
//                                            }, image: "ButtonText")
//                                            BigButton(action: {
//                                                viewModel.showingEmojiInputView.toggle()
//                                            }, image: "ButtonEmoji")
//                                        }
//                                        
//                                    case .trim:
//                                        Text("Work in progress")
//                                            .foregroundStyle(.white)
//                                    case .rotate:
                                        HStack {
                                            BigButton(action: {
                                                viewModel.rotateImage()
                                            }, image: "ButtonRotate")
                                            /*BigButton(action: {
                                                viewModel.toggleFitImage()
                                            }, image: "ButtonFit")*/
                                            BigButton(action: {
                                                viewModel.flipped()
                                            }, image: "ButtonFlip")
                                        }
                                        
                                        
                    //                case .time:
                    //                    DurationView()
                                        
                                        
//                                    case .volume:
//                                        DurationView(title: "Volume")
//                                        
//                                    }
//                                }
                                
//                                Spacer()
                                //MARK: - Done Button
                                BigButton(action: {
                                    self.applyFilter()

//                                    viewModel.select
//                                    self.viewModels.selectedImage = imageProject.project.image.compactMap({ UIImage(data: $0) })
                                }, image: selectedTab == .add ? "ButtonDone" : "ButtonDoneCheck")
                            }
                            .frame(width: UIScreen.main.bounds.size.width,height: 310)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(1), Color.black.opacity(1),Color.black.opacity(1)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            
                            // code stop
                            
                            
                        }
                    }
                }
            }
        }
            .toolbarBackground(.clear, for: .bottomBar)
            .background (
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.7), .black]), startPoint: .top, endPoint: .bottom)
            )
            .onPreferenceChange(SelectedEmojiePreferenceKey.self) { value in
                viewModel.emojiOverlay.emoji = value
            }
            .toast(isShowing: $showToast)
            .onAppear {
                imageProject = ImageProject(project: self.project)
                imageProjectData = imageProject.project.image
                viewModel.mainImage = UIImage(data: imageProject.project.image.first!) ?? UIImage(systemName: "questionmark")!
                if showMusicView {
                    showMusicCategoryView.toggle()
                }
            }
            .onDisappear {
                viewModel.isEditing = false
                imageProject = ImageProject(project: Project(name: "", image: [], ratio: .landscape, dateCreated: Date(), timer: 0, selectedTheme: ""))
                imageProjectData = []
            }
            .fullScreenCover(isPresented: $showSelectMediaView) { ModifyMediaSelectionView(presented: $showSelectMediaView) }
            
    }
    
    func applyMainImage(){
        
        if imageProject.project.image.indices.contains(viewModel.index){
            viewModel.mainImage = UIImage(data: imageProject.project.image[viewModel.index])!
            print("main Image applied")
        }
        
    }
    
    func applyFilter(){
        let img = viewModel.applyWatermarks()
        if let data = img.pngData() {
            
            self.project.image[viewModel.index] = data
            
            imageProject.project.image = self.project.image
//                                        viewModel.mainImage = UIImage(data: data)
            viewModel.isEditing.toggle()

            isDragging = false

        }
    }
    
    func multiImageView(data: Data) -> some View {
        
        let setImage = Image(uiImage: UIImage(data: data)!)
            .resizable()
            .scaledToFill()
//        self.applyMainImage()
        switch setRatio {
        case .standard:
            return setImage
//                .aspectRatio(4/3, contentMode: .fit)  // 4:3 Standard aspect ratio
                .frame(width: 100, height: 80)      // Example fixed size (adjust as needed)

        case .portrait:
            return setImage
                .frame(width: 70, height: 120)      // Example size for portrait

        case .landscape:
            return setImage
                .frame(width: 120, height: 70)      // Example size for landscape

        case .square:
            return setImage
                .frame(width: 70, height: 70)      // Example size for square
        }
    }

    
    
}





struct dropDelegate: DropDelegate {
    
    @Binding var isDragging: Bool
    @Binding var isOverTrashcan: Bool

    let currentIndex: Int
    @Binding var imageProject: ImageProject

    
    func performDrop(info: DropInfo) -> Bool {

        
        isDragging = false
        isOverTrashcan = false

        // Check if the item provider contains an index string
            if let item = info.itemProviders(for: ["public.text"]).first {
                item.loadObject(ofClass: NSString.self) { string, error in
                    if let indexString = string as? String, let fromIndex = Int(indexString), fromIndex >= 0, fromIndex < imageProject.project.image.count {
                        DispatchQueue.main.async {
                            // Move the image data from `fromIndex` to `currentIndex`
                            if fromIndex != currentIndex {
                                let imagenew = imageProject.project.image[fromIndex]
                                imageProject.project.image.remove(at: fromIndex)
                                imageProject.project.image.insert(imagenew, at: currentIndex)
                            }
                        }
                    }
                }
                return true
            }
            return false
        }
    
    func dropEntered(info: DropInfo) {
        // Handle visual feedback when a drop enters the target
        print("drags")

    }
    
    func dropExited(info: DropInfo) {
        // Handle visual feedback when a drop exits the target
        isDragging = true
        print("drags")

    }
}

struct TrashcanDropDelegate: DropDelegate {
    @Binding var draggingIndex: Int?
    @Binding var isOverTrashcan: Bool
    @Binding var isDragging: Bool
    
    @Binding var imageProject: ImageProject

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: ["public.text"])
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let draggingIndex = draggingIndex else { return false }
        
        withAnimation {
            imageProject.project.image.remove(at: draggingIndex)
        }
        
        self.draggingIndex = nil
        self.isOverTrashcan = false
        self.isDragging = false
        return true
    }

    func dropEntered(info: DropInfo) {
        isOverTrashcan = true
    }

    func dropExited(info: DropInfo) {
        isOverTrashcan = false
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

