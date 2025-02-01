import SwiftUI

struct SetPricesView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    @State private var errorMessage: String?
    @Binding var isActive: Bool

    var body: some View {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.color2.opacity(0.2), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Title
                    Text("Set Prices for Services")
                        .font(.custom("Vollkorn-Bold", size: 28)) // Custom Font
                        .foregroundColor(.color) // Dark Green
                        .padding(.top, 20)

                    // Services List
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(0..<viewModel.services.count, id: \.self) { index in
                                HStack {
                                    Text(viewModel.services[index].serviceType.capitalized)
                                        .font(.custom("Vollkorn-Medium", size: 18)) // Custom Font
                                        .foregroundColor(.color) // Dark Green

                                    Spacer()

                                    TextField("Enter price", value: $viewModel.services[index].price, format: .number)
                                        .keyboardType(.decimalPad)
                                        .font(.custom("Vollkorn-Regular", size: 16)) // Custom Font
                                        .padding(10)
                                        .frame(width: 100)
                                        .background(Color.color2.opacity(0.3)) // Light Green
                                        .cornerRadius(10)
                                        .shadow(radius: 2)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 3)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.custom("Vollkorn-Medium", size: 14)) // Custom Font
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    // Next Button
                    Button(action: {
                        if validatePrices() {
                            viewModel.navigateToUnavailableDates = true
                        } else {
                            errorMessage = "Please fill in all prices."
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
                    .padding(.horizontal)

                    // Back Button
                    Button(action: {
                        viewModel.navigateToSetPrices = false
                    }) {
                        Text("Back")
                            .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.color) // Dark Green
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationDestination(isPresented: $viewModel.navigateToUnavailableDates) {
                ServiceUnavailableDatesView(viewModel: viewModel, isActive: $isActive)
            }
    }

    // MARK: - Helper Methods

    private func validatePrices() -> Bool {
        return viewModel.services.allSatisfy { $0.price > 0 }
    }
}
