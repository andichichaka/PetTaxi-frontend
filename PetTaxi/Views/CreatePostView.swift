import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @Binding var isActive: Bool
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [UIImage]()
    @State private var description: String = ""
    @State private var serviceTypes: [String] = []
    @State private var animalSizes: [String] = []
    @State private var animalType: String = "Dog"
    @State private var errorMessage: String?
    @StateObject private var viewModel = CreatePostViewModel()

    private let serviceTypeOptions = ["Daily Walking", "Weekly Walking", "Daily Sitting", "Weekly Sitting", "Other"]
    private let animalSizeOptions = ["Mini (0-5kg)", "Small (5-10kg)", "Medium (10-15kg)", "Large (15-25kg)", "Other"]
    private let animalTypeOptions = ["Dog", "Cat", "Both"]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.color2.opacity(0.2), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        Text("Create New Post")
                            .font(.custom("Vollkorn-Bold", size: 28)) // Custom Font
                            .foregroundColor(.color) // Dark Green
                            .padding(.top, 20)

                        // Description Field
                        descriptionField

                        // Animal Type Picker
                        animalTypePicker

                        // Service Type Selection
                        serviceTypeSelection

                        // Animal Size Selection
                        animalSizeSelection

                        // Upload Photo Section
                        uploadPhotoSection

                        // Next Button
                        nextButton

                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.custom("Vollkorn-Medium", size: 14)) // Custom Font
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }

                        // Close Button
                        closeButton
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToSetPrices) {
                SetPricesView(viewModel: viewModel, isActive: $isActive)
            }
        }
    }

    // MARK: - Subviews

    private var descriptionField: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                .foregroundColor(.color) // Dark Green

            TextEditor(text: $description)
                .font(.custom("Vollkorn-Regular", size: 16)) // Custom Font
                .frame(minHeight: 100) // Expandable height
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 2)
        }
    }

    private var animalTypePicker: some View {
        VStack(alignment: .leading) {
            Text("Animal Type")
                .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                .foregroundColor(.color) // Dark Green

            Picker("Select Animal Type", selection: $animalType) {
                ForEach(animalTypeOptions, id: \.self) { type in
                    Text(type)
                        .font(.custom("Vollkorn-Medium", size: 16)) // Custom Font
                        .tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }

    private var serviceTypeSelection: some View {
        VStack(alignment: .leading) {
            Text("Service Types")
                .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                .foregroundColor(.color) // Dark Green

            // Two services per row
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(serviceTypeOptions, id: \.self) { type in
                    Button(action: {
                        if serviceTypes.contains(type) {
                            serviceTypes.removeAll { $0 == type }
                        } else {
                            serviceTypes.append(type)
                        }
                    }) {
                        Text(type)
                            .font(.custom("Vollkorn-Medium", size: 16)) // Custom Font
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(serviceTypes.contains(type) ? Color.color3 : Color.color2.opacity(0.3)) // Mint Green or Light Green
                            .foregroundColor(serviceTypes.contains(type) ? .white : .color) // Dark Green
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                }
            }
        }
    }

    private var animalSizeSelection: some View {
        VStack(alignment: .leading) {
            Text("Animal Sizes")
                .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                .foregroundColor(.color) // Dark Green

            // Two sizes per row
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(animalSizeOptions, id: \.self) { size in
                    Button(action: {
                        if animalSizes.contains(size) {
                            animalSizes.removeAll { $0 == size }
                        } else {
                            animalSizes.append(size)
                        }
                    }) {
                        Text(size)
                            .font(.custom("Vollkorn-Medium", size: 16)) // Custom Font
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(animalSizes.contains(size) ? Color.color3 : Color.color2.opacity(0.3)) // Mint Green or Light Green
                            .foregroundColor(animalSizes.contains(size) ? .white : .color) // Dark Green
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                }
            }
        }
    }

    private var uploadPhotoSection: some View {
        VStack(alignment: .leading) {
            Text("Upload Photos")
                .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                .foregroundColor(.color) // Dark Green

            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(0..<selectedImages.count, id: \.self) { index in
                        Image(uiImage: selectedImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 5)
                    }

                    PhotosPicker(selection: $selectedItems, matching: .any(of: [.images])) {
                        VStack {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.color) // Dark Green
                            Text("Upload")
                                .font(.custom("Vollkorn-Medium", size: 14)) // Custom Font
                                .foregroundColor(.color) // Dark Green
                        }
                        .frame(width: 150, height: 150)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .onChange(of: selectedItems) { _ in
                        Task {
                            selectedImages.removeAll()
                            for item in selectedItems {
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedImages.append(uiImage)
                                }
                            }
                            viewModel.selectedImages = selectedImages
                        }
                    }
                }
            }
        }
    }

    private var nextButton: some View {
        Button(action: {
            if validateForm() {
                // Update the ViewModel before navigating
                viewModel.description = description
                viewModel.animalType = animalType.lowercased()
                viewModel.animalSizes = animalSizes.map { $0.lowercased() }

                viewModel.services = serviceTypes.map { serviceType in
                    CreateServiceRequest(serviceType: serviceType.lowercased(), price: 0.0, unavailableDates: [])
                }

                print("Form Validated. Navigating to SetPricesView.")
                viewModel.navigateToSetPrices = true
                print("\(viewModel.navigateToSetPrices)")
            } else {
                errorMessage = "Please fill in all required fields"
                print("Form Validation Failed.")
            }
        }) {
            Text("Next")
                .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.color3) // Mint Green
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
    }

    private var closeButton: some View {
        Button(action: {
            isActive = false
        }) {
            Text("Close")
                .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.color) // Dark Green
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
    }

    // MARK: - Helper Methods

    private func validateForm() -> Bool {
        return !description.isEmpty &&
            !serviceTypes.isEmpty &&
            !animalSizes.isEmpty
    }
}

#Preview {
    CreatePostView(isActive: .constant(true))
}
