import SwiftUI

struct BookingView: View {
    @ObservedObject var viewModel: BookingViewModel
    let availableServices: [Service] // Only available services
    let unavailableDates: [Date]
    let availableAnimalSizes: [String] // Only available animal sizes
    let animalType: String
    @State private var isCalendarViewActive: Bool = false
    @Binding var isActive: Bool // To close the view

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.color.opacity(0.1), Color.color1]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Services Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose Service")
                            .font(.custom("Vollkorn-Bold", size: 20)) // Custom Font
                            .foregroundColor(.color) // Dark Green

                        if availableServices.isEmpty {
                            Text("No services available")
                                .font(.custom("Vollkorn-Medium", size: 16)) // Custom Font
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(availableServices, id: \.id) { service in
                                serviceSelectionView(for: service)
                            }
                        }
                    }
                    .padding()

                    // Animal Size Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Animal Size")
                            .font(.custom("Vollkorn-Bold", size: 20)) // Custom Font
                            .foregroundColor(.color) // Dark Green

                        if availableAnimalSizes.isEmpty {
                            Text("No sizes available")
                                .font(.custom("Vollkorn-Medium", size: 16)) // Custom Font
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(availableAnimalSizes, id: \.self) { size in
                                sizeSelectionView(for: size)
                            }
                        }
                    }
                    .padding()

                    Spacer()

                    // Next Button
                    Button(action: {
                        viewModel.isDateSelectionActive = true
                    }) {
                        Text("Next")
                            .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.selectedServiceIds.isEmpty ? Color.gray : Color.color3) // Mint Green
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.selectedServiceIds.isEmpty)

                    // Close Button at the Bottom
                    Button(action: {
                        isActive = false // Close the view
                    }) {
                        Text("Close")
                            .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.color) // Dark Green
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationDestination(isPresented: $viewModel.isDateSelectionActive) {
                MultiServiceCalendarView(viewModel: viewModel, services: selectedServices, unavailableDates: unavailableDates)
            }
        }
        .navigationBarBackButtonHidden(true) // Remove the default back button
        .navigationTitle("Request Booking")
    }

    // MARK: - Computed Properties
    private var selectedServices: [Service] {
        availableServices.filter { service in
            guard let serviceId = service.id else { return false }
            return viewModel.selectedServiceIds.contains(serviceId)
        }
    }

    // MARK: - Helper Views and Methods
    private func serviceSelectionView(for service: Service) -> some View {
        let isSelected = viewModel.selectedServiceIds.contains(service.id!)
        return Text(service.serviceType.capitalized)
            .font(.custom("Vollkorn-Medium", size: 16)) // Custom Font
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.color3.opacity(0.7) : Color.color2.opacity(0.3)) // Mint Green or Light Green
            .foregroundColor(isSelected ? .white : .color) // Dark Green
            .cornerRadius(10)
            .shadow(radius: 2)
            .onTapGesture {
                toggleServiceSelection(for: service.id!)
            }
    }

    private func sizeSelectionView(for size: String) -> some View {
        let isSelected = viewModel.selectedAnimalSize == size
        return Text(size)
            .font(.custom("Vollkorn-Medium", size: 16)) // Custom Font
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.color3.opacity(0.7) : Color.color2.opacity(0.3)) // Mint Green or Light Green
            .foregroundColor(isSelected ? .white : .color) // Dark Green
            .cornerRadius(10)
            .shadow(radius: 2)
            .onTapGesture {
                viewModel.selectedAnimalSize = size
            }
    }

    private func toggleServiceSelection(for serviceId: Int) {
        if let index = viewModel.selectedServiceIds.firstIndex(of: serviceId) {
            viewModel.selectedServiceIds.remove(at: index)
        } else {
            viewModel.selectedServiceIds.append(serviceId)
        }
    }
}
