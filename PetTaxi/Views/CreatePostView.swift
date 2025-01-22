////
////  CreatePostView.swift
////  PetTaxi
////
////  Created by Andrey on 12.01.25.
////
//
//import SwiftUI
//import PhotosUI
//
//struct CreatePostView: View {
//    @Binding var isActive: Bool
//    @State private var selectedItems = [PhotosPickerItem]()
//    @State private var selectedImages = [UIImage]()
//    @State private var description: String = ""
//    @State private var serviceTypes: [String] = []
//    @State private var animalSizes: [String] = []
//    @State private var animalType: String = "Dog"
//    @State private var errorMessage: String?
//    @StateObject private var viewModel = CreatePostViewModel()
//
//    private let serviceTypeOptions = ["Daily Walking", "Weekly Walking", "Daily Sitting", "Weekly Sitting", "Other"]
//    private let animalSizeOptions = ["Mini (0-5kg)", "Small (5-10kg)", "Medium (10-15kg)", "Large (15-25kg)", "Other"]
//    private let animalTypeOptions = ["Dog", "Cat", "Both"]
//
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .edgesIgnoringSafeArea(.all)
//
//            ScrollView {
//                VStack(spacing: 20) {
//                    title
//                    descriptionField
//                    animalTypePicker
//                    serviceTypeSelection
//                    animalSizeSelection
//                    uploadPhotoSection
//                    submitButton
//                    if((errorMessage?.isEmpty) != nil){
//                        Text(errorMessage ?? "")
//                            .font(.caption)
//                            .fontWeight(.medium)
//                            .foregroundColor(.red)
//                    }
//                    closeButton
//                }
//                .padding()
//            }
//        }
//        .navigationTitle("Create Post")
//    }
//
//    // MARK: - Subviews
//
//    private var title: some View {
//        Text("Create New Post")
//            .font(.title)
//            .bold()
//            .padding(.top)
//    }
//
//    private var descriptionField: some View {
//        VStack(alignment: .leading) {
//            Text("Description")
//                .font(.headline)
//            TextField("Explain your service...", text: $description)
//                .padding()
//                //.overlay(RoundedRectangle(cornerRadius: 4.0).stroke(Color.gray, lineWidth: 1))
//                .background(Color.white)
//                .frame(height: 60)
//                .cornerRadius(30)
//        }
//    }
//
//    private var animalTypePicker: some View {
//        VStack(alignment: .leading) {
//            Text("Animal Type")
//                .font(.headline)
//            Picker("Select Animal Type", selection: $animalType) {
//                ForEach(animalTypeOptions, id: \.self) { type in
//                    Text(type).tag(type)
//                }
//            }
//            .pickerStyle(SegmentedPickerStyle())
//        }
//    }
//
//    private var serviceTypeSelection: some View {
//        VStack(alignment: .leading) {
//            Text("Service Types")
//                .font(.headline)
//            ScrollView(.horizontal) {
//                LazyHStack(spacing: 10) {
//                    ForEach(serviceTypeOptions, id: \.self) { type in
//                        Toggle(isOn: Binding(
//                            get: { serviceTypes.contains(type) },
//                            set: { isSelected in
//                                if isSelected {
//                                    serviceTypes.append(type)
//                                } else {
//                                    serviceTypes.removeAll { $0 == type }
//                                }
//                            }
//                        )) {
//                            Text(type)
//                        }
//                        .toggleStyle(CheckboxToggleStyle())
//                    }
//                }
//            }
//        }
//    }
//
//    private var animalSizeSelection: some View {
//        VStack(alignment: .leading) {
//            Text("Animal Sizes")
//                .font(.headline)
//            ScrollView(.horizontal) {
//                LazyHStack(spacing: 10) {
//                    ForEach(animalSizeOptions, id: \.self) { size in
//                        Toggle(isOn: Binding(
//                            get: { animalSizes.contains(size) },
//                            set: { isSelected in
//                                if isSelected {
//                                    animalSizes.append(size)
//                                } else {
//                                    animalSizes.removeAll { $0 == size }
//                                }
//                            }
//                        )) {
//                            Text(size)
//                        }
//                        .toggleStyle(CheckboxToggleStyle())
//                    }
//                }
//            }
//        }
//    }
//
//    private var uploadPhotoSection: some View {
//            VStack(alignment: .leading) {
//                Text("Upload Photos")
//                    .font(.headline)
//                ScrollView(.horizontal) {
//                    LazyHStack(spacing: 10) {
//                        ForEach(0..<selectedImages.count, id: \.self) { index in
//                            Image(uiImage: selectedImages[index])
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 150, height: 150)
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
//                                .shadow(radius: 5)
//                        }
//
//                        PhotosPicker(selection: $selectedItems, matching: .any(of: [.images])) {
//                            VStack {
//                                Image(systemName: "photo")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 40, height: 40)
//                                Text("Upload")
//                                    .font(.footnote)
//                                    .foregroundColor(Color.gray)
//                            }
//                            .frame(width: 150, height: 150)
//                            .background(Color.white)
//                            .cornerRadius(10)
//                            .shadow(radius: 5)
//                        }
//                        .onChange(of: selectedItems) { _ in
//                            Task {
//                                selectedImages.removeAll()
//                                for item in selectedItems {
//                                    if let data = try? await item.loadTransferable(type: Data.self),
//                                       let uiImage = UIImage(data: data) {
//                                        selectedImages.append(uiImage)
//                                    }
//                                }
//                                viewModel.selectedImages = selectedImages
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//    private var submitButton: some View {
//            Button(action: {
//                if validateForm() {
//                    viewModel.description = description
//                    viewModel.serviceTypes = serviceTypes.map { $0.lowercased() }
//                    viewModel.animalSizes = animalSizes.map { $0.lowercased() }
//                    viewModel.animalType = animalType.lowercased()
//                    viewModel.createPost { success in
//                        if success {
//                            isActive = false
//                        } else {
//                            errorMessage = viewModel.errorMessage
//                        }
//                    }
//                } else {
//                    errorMessage = "Please fill in all required fields"
//                }
//            }) {
//                Text("Submit")
//                    .bold()
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.yellow)
//                    .cornerRadius(8)
//                    .foregroundColor(.white)
//                    .shadow(radius: 5)
//            }
//            .padding(.top)
//        }
//    
//    private var closeButton: some View {
//            Button(action: {
//                isActive = false // Dismiss the view
//            }) {
//                Text("Close")
//                    .bold()
//                    .frame(width: 100)
//                    .padding()
//                    .background(Color.red)
//                    .cornerRadius(60)
//                    .foregroundColor(.white)
//                    .shadow(radius: 5)
//            }
////            .padding(.top)
//        }
//
//
//    // MARK: - Validation
//    private func validateForm() -> Bool {
//        return !description.isEmpty &&
//            !serviceTypes.isEmpty &&
//            !animalSizes.isEmpty
//    }
//}
//
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
//
//
//#Preview{
//    CreatePostView(isActive: .constant(true))
//}

import SwiftUI
import _PhotosUI_SwiftUI

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
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        title
                        descriptionField
                        animalTypePicker
                        serviceTypeSelection
                        animalSizeSelection
                        uploadPhotoSection
                        nextButton
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                        }
                        closeButton
                    }
                    .padding()
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToSetPrices) {
            SetPricesView(viewModel: viewModel)
        }

        .navigationTitle("Create Post")
    }

    private var title: some View {
        Text("Create New Post")
            .font(.title)
            .bold()
            .padding(.top)
    }

    private var descriptionField: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .font(.headline)
            TextField("Explain your service...", text: $description)
                .padding()
                .background(Color.white)
                .frame(height: 60)
                .cornerRadius(30)
        }
    }

    private var animalTypePicker: some View {
        VStack(alignment: .leading) {
            Text("Animal Type")
                .font(.headline)
            Picker("Select Animal Type", selection: $animalType) {
                ForEach(animalTypeOptions, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    private var serviceTypeSelection: some View {
        VStack(alignment: .leading) {
            Text("Service Types")
                .font(.headline)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(serviceTypeOptions, id: \.self) { type in
                        Toggle(isOn: Binding(
                            get: { serviceTypes.contains(type) },
                            set: { isSelected in
                                if isSelected {
                                    serviceTypes.append(type)
                                } else {
                                    serviceTypes.removeAll { $0 == type }
                                }
                            }
                        )) {
                            Text(type)
                        }
                        .toggleStyle(CheckboxToggleStyle())
                    }
                }
            }
        }
    }

    private var animalSizeSelection: some View {
        VStack(alignment: .leading) {
            Text("Animal Sizes")
                .font(.headline)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(animalSizeOptions, id: \.self) { size in
                        Toggle(isOn: Binding(
                            get: { animalSizes.contains(size) },
                            set: { isSelected in
                                if isSelected {
                                    animalSizes.append(size)
                                } else {
                                    animalSizes.removeAll { $0 == size }
                                }
                            }
                        )) {
                            Text(size)
                        }
                        .toggleStyle(CheckboxToggleStyle())
                    }
                }
            }
        }
    }

    private var uploadPhotoSection: some View {
        VStack(alignment: .leading) {
            Text("Upload Photos")
                .font(.headline)
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
                            Text("Upload")
                                .font(.footnote)
                                .foregroundColor(Color.gray)
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
        NavigationLink(
            destination: SetPricesView(viewModel: viewModel),
            isActive: $viewModel.navigateToSetPrices // Binding to trigger navigation
        ) {
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
                } else {
                    errorMessage = "Please fill in all required fields"
                    print("Form Validation Failed.")
                }
            }) {
                Text("Next")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
            }
        }
        .padding(.top)
    }



    private var closeButton: some View {
        Button(action: {
            isActive = false
        }) {
            Text("Close")
                .bold()
                .frame(width: 100)
                .padding()
                .background(Color.red)
                .cornerRadius(60)
                .foregroundColor(.white)
                .shadow(radius: 5)
        }
    }

    private func validateForm() -> Bool {
        return !description.isEmpty &&
            !serviceTypes.isEmpty &&
            !animalSizes.isEmpty
    }
}

#Preview{
    CreatePostView(isActive: .constant(true))
}
