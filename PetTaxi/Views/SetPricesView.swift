import SwiftUI

struct SetPricesView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    @State private var errorMessage: String?
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    AppStyle.Colors.secondary.opacity(0.2),
                    AppStyle.Colors.light
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                titleSection
                priceInputs
                if let error = errorMessage { errorText(error) }
                actionButtons
            }
            .padding()
        }
        .navigationDestination(isPresented: $viewModel.navigateToUnavailableDates) {
            ServiceUnavailableDatesView(viewModel: viewModel, isActive: $isActive)
        }
    }

    // MARK: - Subviews

    private var titleSection: some View {
        Text("Set Prices for Services")
            .font(AppStyle.Fonts.vollkornBold(28))
            .foregroundColor(AppStyle.Colors.base)
            .padding(.top, 20)
    }

    private var priceInputs: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(viewModel.services.indices, id: \.self) { index in
                    servicePriceRow(index: index)
                }
            }
            .padding(.horizontal)
        }
    }

    private func servicePriceRow(index: Int) -> some View {
        HStack {
            Text(viewModel.services[index].serviceType.capitalized)
                .font(AppStyle.Fonts.vollkornMedium(18))
                .foregroundColor(AppStyle.Colors.base)

            Spacer()

            TextField("Enter price", value: $viewModel.services[index].price, format: .number)
                .keyboardType(.decimalPad)
                .font(AppStyle.Fonts.vollkornRegular(16))
                .padding(10)
                .frame(width: 100)
                .background(AppStyle.Colors.secondary.opacity(0.3))
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        .padding()
        .background(AppStyle.Colors.light)
        .cornerRadius(15)
        .shadow(radius: 3)
    }

    private func errorText(_ message: String) -> some View {
        Text(message)
            .font(AppStyle.Fonts.vollkornMedium(14))
            .foregroundColor(.red)
            .padding(.horizontal)
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                if validatePrices() {
                    viewModel.navigateToUnavailableDates = true
                } else {
                    errorMessage = "Please fill in all prices."
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
            .padding(.horizontal)

            Button {
                viewModel.navigateToSetPrices = false
            } label: {
                Text("Back")
                    .font(AppStyle.Fonts.vollkornBold(18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppStyle.Colors.base)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Helper

    private func validatePrices() -> Bool {
        viewModel.services.allSatisfy { $0.price > 0 }
    }
}
