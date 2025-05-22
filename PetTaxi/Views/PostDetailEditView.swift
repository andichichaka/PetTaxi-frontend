import SwiftUI
import _PhotosUI_SwiftUI
import Combine

struct PostDetailEditView: View {
    @State var post: Post
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showImagePicker = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var editingServiceIndex: Int?
    @State private var errorMessage: String?
    @State private var showSavePhotosButton = false
    @State private var showEditDatesView = false
    @Environment(\.presentationMode) var presentationMode

    @State private var allLocations: [Location] = []

    private let serviceOptions = ServiceType.allCases.map { $0.rawValue }
    private let sizeOptions = AnimalSize.allCases.map { $0.rawValue }
    private let animalOptions = AnimalType.allCases.map { $0.rawValue }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    imagesSection
                    descriptionSection
                    locationPicker
                    servicesSection
                    animalSizesSection
                    animalTypeSection

                    if let error = errorMessage {
                        Text(error)
                            .font(AppStyle.Fonts.vollkornMedium(14))
                            .foregroundColor(.red)
                            .padding()
                    }

                    actionButtons
                }
            }
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditDatesView) {
                if let index = editingServiceIndex {
                    EditUnavailableDatesView(service: $post.services[index], isPresented: $showEditDatesView)
                }
            }
            .photosPicker(isPresented: $showImagePicker, selection: $selectedItems, matching: .images)
            .onChange(of: selectedItems) { _ in loadSelectedImages() }
            .onAppear {
                loadExistingPostImages()
                fetchLocations()
            }
        }
    }

    // MARK: - Sections

    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Post Images", buttonTitle: "Add Photos") {
                showImagePicker.toggle()
            }

            if !selectedImages.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(selectedImages, id: \.self) { image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 3)

                                Button {
                                    if let index = selectedImages.firstIndex(of: image) {
                                        selectedImages.remove(at: index)
                                        showSavePhotosButton = true
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(.white)
                                        .clipShape(Circle())
                                }
                                .offset(x: -8, y: 8)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            } else {
                Text("No images available")
                    .font(AppStyle.Fonts.vollkornRegular(14))
                    .foregroundColor(AppStyle.Colors.base.opacity(0.7))
                    .padding(.top, 4)
            }

            if showSavePhotosButton {
                Button(action: savePhotos) {
                    Text("Save Photos")
                        .font(AppStyle.Fonts.vollkornBold(16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppStyle.Colors.secondary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
            }
        }
        .padding()
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading) {
            Text("Post Description")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)

            TextEditor(text: $post.description)
                .font(AppStyle.Fonts.vollkornRegular(16))
                .frame(minHeight: 120)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        .padding()
    }

    private var locationPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)

            Picker("Select Location", selection: Binding(
                get: { post.location?.id ?? allLocations.first?.id ?? -1 },
                set: { selectedId in
                    post.location = allLocations.first(where: { $0.id == selectedId })
                })
            ) {
                ForEach(allLocations) { location in
                    Text(location.name)
                        .tag(location.id)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .padding()
    }

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Services")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)

            ForEach(serviceOptions, id: \.self) { type in
                if let index = post.services.firstIndex(where: { $0.serviceType.lowercased() == type.lowercased() }) {
                    serviceRow(for: post.services[index], at: index)
                } else {
                    serviceAddRow(serviceType: type)
                }
            }
        }
        .padding()
    }

    private var animalSizesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Animal Sizes")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)

            ForEach(sizeOptions, id: \.self) { size in
                if let index = post.animalSizes.firstIndex(of: size.lowercased()) {
                    sizeRow(for: size, at: index)
                } else {
                    sizeAddRow(size: size)
                }
            }
        }
        .padding()
    }

    private var animalTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Animal Type")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)

            ForEach(animalOptions, id: \.self) { type in
                HStack {
                    Text(type)
                        .font(AppStyle.Fonts.vollkornMedium(16))
                    Spacer()
                    Image(systemName: post.animalType == type.lowercased() ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(post.animalType == type.lowercased() ? AppStyle.Colors.accent : .gray)
                }
                .onTapGesture {
                    post.animalType = type.lowercased()
                }
                .padding(6)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
            }
        }
        .padding()
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: savePost) {
                Text("Save Post")
                    .font(AppStyle.Fonts.vollkornBold(18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppStyle.Colors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }

            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text("Close")
                    .font(AppStyle.Fonts.vollkornBold(18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppStyle.Colors.base)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
        }
        .padding()
    }

    // MARK: - Reusable Mini Views

    private func serviceRow(for service: Service, at index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(service.serviceType.capitalized)
                    .font(AppStyle.Fonts.vollkornMedium(16))

                Spacer()

                Button("Edit Dates") {
                    editingServiceIndex = index
                    showEditDatesView = true
                }
                .font(AppStyle.Fonts.vollkornMedium(14))
                .padding(6)
                .background(AppStyle.Colors.secondary.opacity(0.7))
                .cornerRadius(8)
                .foregroundColor(.white)

                Button {
                    post.services.remove(at: index)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }

            HStack {
                Text("Price:")
                TextField("Price", value: $post.services[index].price, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
            }
            .font(AppStyle.Fonts.vollkornRegular(16))
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private func serviceAddRow(serviceType: String) -> some View {
        HStack {
            Text(serviceType.capitalized)
                .font(AppStyle.Fonts.vollkornMedium(16))
            Spacer()
            Button("Add Service") {
                addNewService(ofType: serviceType)
            }
            .font(AppStyle.Fonts.vollkornMedium(14))
            .padding(6)
            .background(AppStyle.Colors.accent.opacity(0.7))
            .cornerRadius(8)
            .foregroundColor(.white)
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private func sizeRow(for size: String, at index: Int) -> some View {
        HStack {
            Text(size)
                .font(AppStyle.Fonts.vollkornMedium(16))
            Spacer()
            Button {
                post.animalSizes.remove(at: index)
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private func sizeAddRow(size: String) -> some View {
        HStack {
            Text(size)
                .font(AppStyle.Fonts.vollkornMedium(16))
            Spacer()
            Button("Add Size") {
                post.animalSizes.append(size.lowercased())
            }
            .font(AppStyle.Fonts.vollkornMedium(14))
            .padding(6)
            .background(AppStyle.Colors.accent.opacity(0.7))
            .cornerRadius(8)
            .foregroundColor(.white)
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private func sectionHeader(_ title: String, buttonTitle: String, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)
            Spacer()
            Button(buttonTitle, action: action)
                .font(AppStyle.Fonts.vollkornMedium(16))
                .foregroundColor(AppStyle.Colors.accent)
        }
    }

    // MARK: - Logic

    private func fetchLocations() {
        CommunicationManager.shared.execute(
            endpoint: .getAllLocations,
            responseType: [Location].self
        ) { result in
            DispatchQueue.main.async {
                if case let .success(locations) = result {
                    allLocations = locations
                }
            }
        }
    }

    private func savePost() {
        guard !post.services.isEmpty else {
            errorMessage = "You must select at least one service."
            return
        }
        viewModel.updatePost(post: post)
        presentationMode.wrappedValue.dismiss()
    }

    private func savePhotos() {
        viewModel.updatePostImages(postId: post.id, images: selectedImages)
        showSavePhotosButton = false
    }

    private func addNewService(ofType type: String) {
        post.services.append(Service(id: nil, bookings: nil, serviceType: type.lowercased(), price: 0.0, unavailableDates: [], post: nil))
    }

    private func loadSelectedImages() {
        Task {
            for item in selectedItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImages.append(uiImage)
                }
            }
            showSavePhotosButton = true
        }
    }

    private func loadExistingPostImages() {
        Task {
            guard let imageUrls = post.imagesUrl else { return }
            for url in imageUrls {
                if let url = URL(string: url),
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    selectedImages.append(image)
                }
            }
        }
    }
}
