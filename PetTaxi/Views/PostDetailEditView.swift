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

    let allServiceTypeOptions = ["Daily Walking", "Weekly Walking", "Daily Sitting", "Weekly Sitting", "Other"]
    let allAnimalSizeOptions = ["Mini (0-5kg)", "Small (5-10kg)", "Medium (10-15kg)", "Large (15-25kg)", "Other"]
    let allAnimalTypeOptions = ["Dog", "Cat", "Both"]
    @State private var allLocations: [Location] = []

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

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.custom("Vollkorn-Medium", size: 14))
                            .foregroundColor(.red)
                            .padding()
                    }

                    Button(action: savePost) {
                        Text("Save Post")
                            .font(.custom("Vollkorn-Bold", size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.color3)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    .padding()

                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Close")
                            .font(.custom("Vollkorn-Bold", size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.color)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    .padding()
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
            .onChange(of: selectedItems) { _ in
                loadSelectedImages()
            }
            .onAppear {
                loadExistingPostImages()
                fetchLocations()
            }
        }
    }
    
    private func fetchLocations() {
        CommunicationManager.shared.execute(
            endpoint: .getAllLocations,
            responseType: [Location].self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    allLocations = locations
                case .failure(let error):
                    print("Failed to load locations: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Post Images Section
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Post Images")
                    .font(.custom("Vollkorn-Bold", size: 18))
                    .foregroundColor(.color)
                Spacer()
                Button(action: { showImagePicker.toggle() }) {
                    Text("Add Photos")
                        .font(.custom("Vollkorn-Medium", size: 16))
                        .foregroundColor(.color3)
                }
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

                                Button(action: {
                                    if let index = selectedImages.firstIndex(of: image) {
                                        selectedImages.remove(at: index)
                                        showSavePhotosButton = true
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                .offset(x: -8, y: 8)
                            }
                        }
                    }
                }
                .padding()
            } else {
                Text("No images available")
                    .font(.custom("Vollkorn-Regular", size: 14))
                    .foregroundColor(.color.opacity(0.7))
                    .padding()
            }

            if showSavePhotosButton {
                Button(action: savePhotos) {
                    Text("Save Photos")
                        .font(.custom("Vollkorn-Bold", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.color2)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                .padding(.top)
            }
        }
        .padding()
    }

    // MARK: - Post Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading) {
            Text("Post Description")
                .font(.custom("Vollkorn-Bold", size: 18))
                .foregroundColor(.color)
            TextEditor(text: $post.description)
                .font(.custom("Vollkorn-Regular", size: 16))
                .frame(minHeight: 120)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        .padding()
    }
    
    // MARK: - Locations picker Section
    private var locationPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location")
                .font(.custom("Vollkorn-Bold", size: 18))
                .foregroundColor(.color)

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

    // MARK: - Services Section
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Services")
                .font(.custom("Vollkorn-Bold", size: 18))
                .foregroundColor(.color)
            
            ForEach(allServiceTypeOptions, id: \.self) { serviceType in
                if let index = post.services.firstIndex(where: { $0.serviceType.lowercased() == serviceType.lowercased() }) {
                    serviceRow(for: post.services[index], at: index)
                } else {
                    HStack {
                        Text(serviceType.capitalized)
                            .font(.custom("Vollkorn-Medium", size: 16))
                            .foregroundColor(.color)
                        Spacer()
                        Button(action: {
                            addNewService(ofType: serviceType)
                        }) {
                            Text("Add Service")
                                .font(.custom("Vollkorn-Medium", size: 14))
                                .padding(6)
                                .background(Color.color3.opacity(0.7))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
            }
        }
        .padding()
    }

    // MARK: - Animal Sizes Section
    private var animalSizesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Animal Sizes")
                .font(.custom("Vollkorn-Bold", size: 18))
                .foregroundColor(.color)

            ForEach(allAnimalSizeOptions, id: \.self) { size in
                if let index = post.animalSizes.firstIndex(of: size.lowercased()) {
                    animalSizeRow(for: size, at: index)
                } else {
                    HStack {
                        Text(size)
                            .font(.custom("Vollkorn-Medium", size: 16))
                            .foregroundColor(.color)
                        Spacer()
                        Button(action: {
                            post.animalSizes.append(size.lowercased())
                        }) {
                            Text("Add Size")
                                .font(.custom("Vollkorn-Medium", size: 14))
                                .padding(6)
                                .background(Color.color3.opacity(0.7))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
            }
        }
        .padding()
    }

    private func animalSizeRow(for size: String, at index: Int) -> some View {
        HStack {
            Text(size)
                .font(.custom("Vollkorn-Medium", size: 16))
                .foregroundColor(.color)
            Spacer()
            Button(action: {
                post.animalSizes.remove(at: index)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    // MARK: - Animal Type Section
    private var animalTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Animal Type")
                .font(.custom("Vollkorn-Bold", size: 18))
                .foregroundColor(.color)

            ForEach(allAnimalTypeOptions, id: \.self) { type in
                HStack {
                    Text(type)
                        .font(.custom("Vollkorn-Medium", size: 16))
                        .foregroundColor(.color)
                    Spacer()
                    Button(action: {
                        post.animalType = type.lowercased()
                    }) {
                        Image(systemName: post.animalType == type.lowercased() ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(post.animalType == type.lowercased() ? .color3 : .gray)
                    }
                }
                .padding(6)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
            }
        }
        .padding()
    }
    
    private func serviceRow(for service: Service, at index: Int) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(post.services[index].serviceType.capitalized)
                        .font(.custom("Vollkorn-Medium", size: 16))
                        .foregroundColor(.color)

                    Spacer()

                    Button(action: {
                        editingServiceIndex = index
                        showEditDatesView = true
                    }) {
                        Text("Edit Dates")
                            .font(.custom("Vollkorn-Medium", size: 14))
                            .padding(6)
                            .background(Color.color2.opacity(0.7))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    Button(action: {
                        post.services.remove(at: index)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }

                HStack {
                    Text("Price:")
                        .font(.custom("Vollkorn-Medium", size: 16))
                        .foregroundColor(.color)
                    TextField("Price", value: $post.services[index].price, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                        .font(.custom("Vollkorn-Regular", size: 16))
                }
            }
            .padding(6)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }

    // MARK: - Helper Methods
    private func savePost() {
        if post.services.isEmpty {
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
                if let url = URL(string: url), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    selectedImages.append(image)
                }
            }
        }
    }
}
