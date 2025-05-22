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
                LinearGradient(
                    gradient: Gradient(colors: [AppStyle.Colors.base.opacity(0.1), AppStyle.Colors.light]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    serviceSelectionSection
                    animalSizeSelectionSection
                    Spacer()
                    nextButton
                    closeButton
                }
            }
            .navigationDestination(isPresented: $viewModel.isDateSelectionActive) {
                MultiServiceCalendarView(
                    viewModel: viewModel,
                    services: selectedServices,
                    unavailableDates: unavailableDates
                )
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

    // MARK: - Sections
    private var serviceSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Service")
                .font(AppStyle.Fonts.vollkornBold(20))
                .foregroundColor(AppStyle.Colors.base)

            if availableServices.isEmpty {
                Text("No services available")
                    .font(AppStyle.Fonts.vollkornMedium(16))
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(availableServices, id: \ .id) { service in
                    serviceSelectionView(for: service)
                }
            }
        }
        .padding()
    }

    private var animalSizeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Animal Size")
                .font(AppStyle.Fonts.vollkornBold(20))
                .foregroundColor(AppStyle.Colors.base)

            if availableAnimalSizes.isEmpty {
                Text("No sizes available")
                    .font(AppStyle.Fonts.vollkornMedium(16))
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(availableAnimalSizes, id: \ .self) { size in
                    sizeSelectionView(for: size)
                }
            }
        }
        .padding()
    }

    private var nextButton: some View {
        Button(action: {
            viewModel.isDateSelectionActive = true
        }) {
            Text("Next")
                .font(AppStyle.Fonts.vollkornBold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.selectedServiceIds.isEmpty ? Color.gray : AppStyle.Colors.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        .padding(.horizontal)
        .disabled(viewModel.selectedServiceIds.isEmpty)
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
        .padding(.horizontal)
        .padding(.bottom, 20)
    }

    // MARK: - Helper Views
    private func serviceSelectionView(for service: Service) -> some View {
        let isSelected = viewModel.selectedServiceIds.contains(service.id!)
        return Text(service.serviceType.capitalized)
            .font(AppStyle.Fonts.vollkornMedium(16))
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? AppStyle.Colors.accent.opacity(0.7) : AppStyle.Colors.secondary.opacity(0.3))
            .foregroundColor(isSelected ? .white : AppStyle.Colors.base)
            .cornerRadius(10)
            .shadow(radius: 2)
            .onTapGesture {
                toggleServiceSelection(for: service.id!)
            }
    }

    private func sizeSelectionView(for size: String) -> some View {
        let isSelected = viewModel.selectedAnimalSize == size
        return Text(size)
            .font(AppStyle.Fonts.vollkornMedium(16))
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? AppStyle.Colors.accent.opacity(0.7) : AppStyle.Colors.secondary.opacity(0.3))
            .foregroundColor(isSelected ? .white : AppStyle.Colors.base)
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
