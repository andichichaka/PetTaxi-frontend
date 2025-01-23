import SwiftUI

struct BookingView: View {
    @ObservedObject private var viewModel: BookingViewModel
    let services: [Service]
    let unavailableDates: [Date]

    init(viewModel: BookingViewModel, services: [Service], unavailableDates: [Date]) {
        self.viewModel = viewModel
        self.services = services
        self.unavailableDates = unavailableDates
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Services Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose Service")
                        .font(.headline)
                    ForEach(services, id: \.id) { service in
                        serviceSelectionView(for: service)
                    }
                }
                .padding()

                // Animal Size Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Animal Size")
                        .font(.headline)
                    ForEach(["Mini (0-5kg)", "Small (5-10kg)", "Medium (10-15kg)", "Large (15-25kg)", "Other"], id: \.self) { size in
                        sizeSelectionView(for: size)
                    }
                }
                .padding()

                // Navigation to Date Selection
                NavigationLink(
                    destination: MultiServiceCalendarView(viewModel: viewModel, services: services, unavailableDates: unavailableDates)
                ) {
                    Text("Next")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle("Request Booking")
            .background(LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        }
    }

    // MARK: - Helper Views

    private func serviceSelectionView(for service: Service) -> some View {
        let isSelected = viewModel.selectedServiceIds.contains(service.id!)
        return Text(service.serviceType.capitalized)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.yellow.opacity(0.7) : Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
            .onTapGesture {
                toggleServiceSelection(for: service.id!)
            }
    }

    private func sizeSelectionView(for size: String) -> some View {
        let isSelected = viewModel.selectedAnimalSize == size
        return Text(size)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.yellow.opacity(0.7) : Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
            .onTapGesture {
                viewModel.selectedAnimalSize = size
            }
    }

    // MARK: - Helper Methods

    private func toggleServiceSelection(for serviceId: Int) {
        if let index = viewModel.selectedServiceIds.firstIndex(of: serviceId) {
            viewModel.selectedServiceIds.remove(at: index)
        } else {
            viewModel.selectedServiceIds.append(serviceId)
        }
    }
}
