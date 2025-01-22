//
//  SetPricesView.swift
//  PetTaxi
//
//  Created by Andrey on 21.01.25.
//

import SwiftUI

struct SetPricesView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Prices for Services")
                .font(.title)
                .bold()

            ScrollView {
                VStack(spacing: 15) {
                    ForEach(0..<viewModel.services.count, id: \.self) { index in
                        HStack {
                            Text(viewModel.services[index].serviceType.capitalized)
                                .fontWeight(.medium)
                            Spacer()
                            TextField("Enter price", value: $viewModel.services[index].price, format: .number)
                                .keyboardType(.decimalPad)
                                .padding(10)
                                .frame(width: 100)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                if validatePrices() {
                    viewModel.navigateToUnavailableDates = true
                } else {
                    errorMessage = "Please fill in all prices."
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
            .padding(.horizontal)

            Button("Back") {
                viewModel.navigateToSetPrices = false
            }
            .padding(.top, 10)
            .foregroundColor(.red)
        }
        .padding()
        .navigationDestination(isPresented: $viewModel.navigateToUnavailableDates) {
            ServiceUnavailableDatesView(viewModel: viewModel)
        }
    }

    private func validatePrices() -> Bool {
        return viewModel.services.allSatisfy { $0.price > 0 }
    }
}
