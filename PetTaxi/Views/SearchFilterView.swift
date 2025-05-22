import SwiftUI

struct SearchFilterView: View {
    @Binding var isActive: Bool
    @StateObject private var viewModel = SearchFilterViewModel()
    @State private var navigateToResults = false
    @Environment(\.dismiss) var dismiss

    private let serviceTypeOptions = ServiceType.allCases.map { $0.rawValue }
    private let animalSizeOptions = AnimalSize.allCases.map { $0.rawValue }
    private let animalTypeOptions = AnimalType.allCases.map { $0.rawValue }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [AppStyle.Colors.secondary.opacity(0.2), AppStyle.Colors.light]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    filterForm

                    Spacer()

                    closeButton
                }
            }
            .fullScreenCover(isPresented: $navigateToResults) {
                FilteredPostsView(isActive: $navigateToResults, viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchLocations()
            }
        }
    }

    private var filterForm: some View {
        VStack(spacing: 20) {
            keywordField

            VStack {
                HStack(spacing: 20) {
                    serviceTypeSection
                    VStack(spacing: 10) {
                        animalTypePicker
                        animalSizesSection
                    }
                }
                locationPicker
            }
            .padding()
            .background(AppStyle.Colors.light)
            .cornerRadius(10)
            .shadow(radius: 2)

            actionButtons
        }
        .padding()
        .frame(width: 350, height: 600)
        .background(AppStyle.Colors.light)
        .cornerRadius(20)
        .shadow(radius: 10)
    }

    private var keywordField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Keywords...", text: $viewModel.keyword)
                .font(AppStyle.Fonts.vollkornRegular(16))
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(AppStyle.Colors.light)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private var serviceTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Service Types")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(serviceTypeOptions, id: \.self) { type in
                        Toggle(isOn: Binding(
                            get: { viewModel.serviceTypes.contains(type) },
                            set: { isSelected in
                                if isSelected {
                                    viewModel.serviceTypes.append(type)
                                } else {
                                    viewModel.serviceTypes.removeAll { $0 == type }
                                }
                            }
                        )) {
                            Text(type)
                                .font(AppStyle.Fonts.vollkornMedium(16))
                                .foregroundColor(AppStyle.Colors.base)
                        }
                        .toggleStyle(CheckboxToggleStyle())
                    }
                }
            }
        }
    }

    private var animalTypePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Animal Type")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)
            Picker("Select type", selection: $viewModel.animalType) {
                Text("Select type").tag("").font(AppStyle.Fonts.vollkornMedium(16))
                ForEach(animalTypeOptions, id: \.self) { type in
                    Text(type)
                        .font(AppStyle.Fonts.vollkornMedium(16))
                        .tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .background(AppStyle.Colors.light)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }

    private var animalSizesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Animal Sizes")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(animalSizeOptions, id: \.self) { size in
                        Toggle(isOn: Binding(
                            get: { viewModel.animalSizes.contains(size) },
                            set: { isSelected in
                                if isSelected {
                                    viewModel.animalSizes.append(size)
                                } else {
                                    viewModel.animalSizes.removeAll { $0 == size }
                                }
                            }
                        )) {
                            Text(size)
                                .font(AppStyle.Fonts.vollkornMedium(16))
                                .foregroundColor(AppStyle.Colors.base)
                        }
                        .toggleStyle(CheckboxToggleStyle())
                    }
                }
            }
        }
    }

    private var locationPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location")
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(AppStyle.Colors.base)

            Picker("Select Location", selection: $viewModel.selectedLocationId) {
                Text("Any Location").tag(nil as Int?)
                ForEach(viewModel.locations) { location in
                    Text(location.name).tag(location.id as Int?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: .infinity)
            .padding(10)
            .background(AppStyle.Colors.light)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .padding(.leading, -125)
    }

    private var actionButtons: some View {
        HStack {
            Button(action: {
                viewModel.performSearch { success in
                    if success {
                        navigateToResults = true
                    } else {
                        print(viewModel.errorMessage ?? "Unknown error")
                    }
                }
            }) {
                Text("Search")
                    .font(AppStyle.Fonts.vollkornBold(18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppStyle.Colors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }

            Button(action: {
                viewModel.clearFilters()
            }) {
                Text("Clear")
                    .font(AppStyle.Fonts.vollkornBold(18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppStyle.Colors.secondary.opacity(0.3))
                    .foregroundColor(AppStyle.Colors.base)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
        }
    }

    private var closeButton: some View {
        Button(action: {
            isActive = false
        }) {
            Text("Close")
                .font(AppStyle.Fonts.vollkornBold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppStyle.Colors.base)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        .padding(.horizontal, 50)
        .padding(.bottom, 20)
    }
}

// MARK: - Preview
struct SearchFilterView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFilterView(isActive: .constant(true))
    }
}
