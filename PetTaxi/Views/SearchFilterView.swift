import SwiftUI

struct SearchFilterView: View {
    @Binding var isActive: Bool
    @StateObject private var viewModel = SearchFilterViewModel()
    @State private var navigateToResults = false
    @Environment(\.dismiss) var dismiss
    
    private let serviceTypeOptions = ["Daily Walking", "Weekly Walking", "Daily Sitting", "Weekly Sitting", "Other"]
    private let animalSizeOptions = ["Mini (0-5kg)", "Small (5-10kg)", "Medium (10-15kg)", "Large (15-25kg)", "Other"]
    private let animalTypeOptions = ["Dog", "Cat", "Both"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.color2.opacity(0.2), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Keywords...", text: $viewModel.keyword)
                                .font(.custom("Vollkorn-Regular", size: 16))
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Service Types")
                                    .font(.custom("Vollkorn-Bold", size: 18))
                                    .foregroundColor(.color)
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
                                                    .font(.custom("Vollkorn-Medium", size: 16))
                                                    .foregroundColor(.color)
                                            }
                                            .toggleStyle(CheckboxToggleStyle())
                                        }
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Animal Type")
                                        .font(.custom("Vollkorn-Bold", size: 18))
                                        .foregroundColor(.color)
                                    Picker("Select type", selection: $viewModel.animalType) {
                                        Text("Select type").tag("")
                                            .font(.custom("Vollkorn-Medium", size: 16))
                                        ForEach(animalTypeOptions, id: \.self) { type in
                                            Text(type)
                                                .font(.custom("Vollkorn-Medium", size: 16))
                                                .tag(type)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Animal Sizes")
                                        .font(.custom("Vollkorn-Bold", size: 18))
                                        .foregroundColor(.color)
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
                                                        .font(.custom("Vollkorn-Medium", size: 16))
                                                        .foregroundColor(.color)
                                                }
                                                .toggleStyle(CheckboxToggleStyle())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        
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
                                    .font(.custom("Vollkorn-Bold", size: 18))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.color3)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                            }
                            Button(action: {
                                viewModel.clearFilters()
                            }) {
                                Text("Clear")
                                    .font(.custom("Vollkorn-Bold", size: 18))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.color2.opacity(0.3))
                                    .foregroundColor(.color)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .padding()
                    .frame(width: 350, height: 600)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    
                    Spacer()
                    
                    Button(action: {
                        isActive = false
                    }) {
                        Text("Close")
                            .font(.custom("Vollkorn-Bold", size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.color)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 20)
                }
            }
            .fullScreenCover(isPresented: $navigateToResults) {
                FilteredPostsView(isActive: $navigateToResults, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Preview
struct SearchFilterView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFilterView(isActive: .constant(true))
    }
}
