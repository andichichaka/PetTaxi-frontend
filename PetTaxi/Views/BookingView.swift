import SwiftUI

struct BookingView: View {
    @ObservedObject var viewModel: BookingViewModel
    let availableServices: [Service]
    let unavailableDates: [Date]
    let availableAnimalSizes: [String]
    let animalType: String
    @State private var isCalendarViewActive: Bool = false
    @Binding var isActive: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.color.opacity(0.1), Color.color1]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose Service")
                            .font(.custom("Vollkorn-Bold", size: 20))
                            .foregroundColor(.color)

                        if availableServices.isEmpty {
                            Text("No services available")
                                .font(.custom("Vollkorn-Medium", size: 16))
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(availableServices, id: \.id) { service in
                                serviceSelectionView(for: service)
                            }
                        }
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Animal Size")
                            .font(.custom("Vollkorn-Bold", size: 20))
                            .foregroundColor(.color)

                        if availableAnimalSizes.isEmpty {
                            Text("No sizes available")
                                .font(.custom("Vollkorn-Medium", size: 16))
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

                    Button(action: {
                        viewModel.isDateSelectionActive = true
                    }) {
                        Text("Next")
                            .font(.custom("Vollkorn-Bold", size: 18))
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.selectedServiceIds.isEmpty ? Color.gray : Color.color3)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.selectedServiceIds.isEmpty)

                    Button(action: {
                        isActive = false
                    }) {
                        Text("Close")
                            .font(.custom("Vollkorn-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.color)
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
        .navigationBarBackButtonHidden(true)
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
            .font(.custom("Vollkorn-Medium", size: 16))
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.color3.opacity(0.7) : Color.color2.opacity(0.3))
            .foregroundColor(isSelected ? .white : .color)
            .cornerRadius(10)
            .shadow(radius: 2)
            .onTapGesture {
                toggleServiceSelection(for: service.id!)
            }
    }

    private func sizeSelectionView(for size: String) -> some View {
        let isSelected = viewModel.selectedAnimalSize == size
        return Text(size)
            .font(.custom("Vollkorn-Medium", size: 16))
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.color3.opacity(0.7) : Color.color2.opacity(0.3))
            .foregroundColor(isSelected ? .white : .color)
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
