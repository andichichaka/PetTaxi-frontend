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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Post Images Section
                    imagesSection

                    // Post Description Section
                    descriptionSection

                    // Services Section
                    servicesSection

                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }

                    // Save Post Button
                    Button(action: savePost) {
                        Text("Save Post")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    // Close Button
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Close")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
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
            }
        }
    }

    // MARK: - Post Images Section
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Post Images")
                    .font(.headline)
                Spacer()
                Button(action: { showImagePicker.toggle() }) {
                    Text("Add Photos")
                        .foregroundColor(.blue)
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

                                // Remove Image Button
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
                    .foregroundColor(.secondary)
                    .padding()
            }

            if showSavePhotosButton {
                Button(action: savePhotos) {
                    Text("Save Photos")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
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
                .font(.headline)
            TextEditor(text: $post.description)
                .frame(minHeight: 120)
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
                .font(.headline)

            ForEach(allServiceTypeOptions, id: \.self) { serviceType in
                if let index = post.services.firstIndex(where: { $0.serviceType.lowercased() == serviceType.lowercased() }) {
                    // Existing Service
                    serviceRow(for: post.services[index], at: index)
                } else {
                    // Add Missing Service
                    HStack {
                        Text(serviceType.capitalized)
                            .font(.subheadline)
                        Spacer()
                        Button(action: {
                            addNewService(ofType: serviceType)
                        }) {
                            Text("Add Service")
                                .font(.caption)
                                .padding(6)
                                .background(Color.blue.opacity(0.7))
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

    private func serviceRow(for service: Service, at index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(post.services[index].serviceType.capitalized)
                    .font(.subheadline)

                Spacer()

                Button(action: {
                    editingServiceIndex = index
                    showEditDatesView = true
                }) {
                    Text("Edit Dates")
                        .font(.caption)
                        .padding(6)
                        .background(Color.yellow.opacity(0.7))
                        .cornerRadius(8)
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
                TextField("Price", value: $post.services[index].price, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
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

    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
            .foregroundColor(.gray)
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(10)
    }
}
