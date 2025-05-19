import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @Binding var isActive: Bool
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [UIImage]()
    @State private var description: String = ""
    @State private var serviceTypes: [ServiceType] = []
    @State private var animalSizes: [AnimalSize] = []
    @State private var animalType: AnimalType = .dog
    @State private var errorMessage: String?
    @StateObject private var viewModel = CreatePostViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [AppStyle.Colors.secondary.opacity(0.2), .white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Create New Post")
                            .font(AppStyle.Fonts.vollkornBold(28))
                            .foregroundColor(AppStyle.Colors.base)
                            .padding(.top, 20)

                        descriptionField
                        locationPicker
                        animalTypePicker
                        serviceTypeSelection
                        animalSizeSelection
                        uploadPhotoSection

                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppStyle.Fonts.vollkornMedium(14))
                                .foregroundColor(.red)
                        }

                        nextButton
                        closeButton
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToSetPrices) {
                SetPricesView(viewModel: viewModel, isActive: $isActive)
            }
        }
        .onAppear {
            viewModel.fetchLocations()
        }
    }

    // MARK: - Subviews

    private var descriptionField: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)

            TextEditor(text: $description)
                .font(AppStyle.Fonts.vollkornRegular(16))
                .frame(minHeight: 100)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 2)
        }
    }

    private var locationPicker: some View {
          VStack(alignment: .leading) {
              Text("Select Location")
                  .font(AppStyle.Fonts.vollkornBold(18))
                  .foregroundColor(AppStyle.Colors.base)

              Picker("Location", selection: $viewModel.selectedLocationId) {
                  ForEach(viewModel.locations) { location in
                      Text(location.name).tag(location.id as Int?)
                  }
              }
              .pickerStyle(MenuPickerStyle())
              .frame(maxWidth: .infinity)
              .padding()
              .background(.white)
              .cornerRadius(10)
              .shadow(radius: 2)
          }
      }

    private var animalTypePicker: some View {
        VStack(alignment: .leading) {
            Text("Animal Type")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)

            Picker("Select Animal Type", selection: $animalType) {
                ForEach(AnimalType.allCases) { type in
                    Text(type.rawValue)
                        .font(AppStyle.Fonts.vollkornMedium(16))
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
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(ServiceType.allCases) { service in
                    ToggleButton(
                        label: service.rawValue,
                        isSelected: serviceTypes.contains(service),
                        onTap: {
                            if serviceTypes.contains(service) {
                                serviceTypes.removeAll { $0 == service }
                            } else {
                                serviceTypes.append(service)
                            }
                        }
                    )
                }
            }
        }
    }

    private var animalSizeSelection: some View {
        VStack(alignment: .leading) {
            Text("Animal Sizes")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(AnimalSize.allCases) { size in
                    ToggleButton(
                        label: size.rawValue,
                        isSelected: animalSizes.contains(size),
                        onTap: {
                            if animalSizes.contains(size) {
                                animalSizes.removeAll { $0 == size }
                            } else {
                                animalSizes.append(size)
                            }
                        }
                    )
                }
            }
        }
    }

    private var uploadPhotoSection: some View {
        VStack(alignment: .leading) {
            Text("Upload Photos")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
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
                                .foregroundColor(AppStyle.Colors.base)

                            Text("Upload")
                                .font(AppStyle.Fonts.vollkornMedium(14))
                                .foregroundColor(AppStyle.Colors.base)
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
                                   let image = UIImage(data: data) {
                                    selectedImages.append(image)
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
        Button {
            if validateForm() {
                viewModel.description = description
                viewModel.animalType = animalType.rawValue.lowercased()
                viewModel.animalSizes = animalSizes.map { $0.rawValue.lowercased() }
                viewModel.services = serviceTypes.map {
                    CreateServiceRequest(serviceType: $0.rawValue.lowercased(), price: 0.0, unavailableDates: [])
                }
                viewModel.navigateToSetPrices = true
            } else {
                errorMessage = "Please fill in all required fields"
            }
        } label: {
            Text("Next")
                .font(AppStyle.Fonts.vollkornBold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppStyle.Colors.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
    }

    private var closeButton: some View {
        Button {
            isActive = false
        } label: {
            Text("Close")
                .font(AppStyle.Fonts.vollkornBold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppStyle.Colors.base)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
    }

    private func validateForm() -> Bool {
        !description.isEmpty &&
        !serviceTypes.isEmpty &&
        !animalSizes.isEmpty &&
        viewModel.selectedLocationId != nil
    }
}

// MARK: - Mini reusable toggle view

private struct ToggleButton: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(label)
            .font(AppStyle.Fonts.vollkornMedium(16))
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? AppStyle.Colors.accent : AppStyle.Colors.secondary.opacity(0.3))
            .foregroundColor(isSelected ? .white : AppStyle.Colors.base)
            .cornerRadius(10)
            .shadow(radius: 2)
            .onTapGesture(perform: onTap)
    }
}

#Preview {
    CreatePostView(isActive: .constant(true))
}
