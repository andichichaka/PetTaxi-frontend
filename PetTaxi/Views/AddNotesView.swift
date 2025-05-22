import SwiftUI

struct AddNotesView: View {
    @ObservedObject var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSubmitting = false

    var body: some View {
        ZStack {
            gradientBackground

            VStack(spacing: 20) {
                title
                notesEditorSection
                errorMessageView
                Spacer()
                submitButton
            }
            .padding()
        }
        .navigationTitle("Add Notes")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var gradientBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [AppStyle.Colors.accent.opacity(0.4), AppStyle.Colors.secondary.opacity(0.2)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var title: some View {
        Text("Add Notes")
            .font(AppStyle.Fonts.vollkornBold(28))
            .foregroundColor(AppStyle.Colors.base)
            .padding(.top, 20)
    }

    private var notesEditorSection: some View {
        VStack(alignment: .leading) {
            Text("Notes for the service provider")
                .font(AppStyle.Fonts.vollkornMedium(16))
                .foregroundColor(.gray)

            TextEditor(text: $viewModel.notes)
                .font(AppStyle.Fonts.vollkornRegular(16))
                .frame(height: 150)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        .padding(.horizontal)
    }

    private var errorMessageView: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(AppStyle.Fonts.vollkornMedium(14))
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
    }

    private var submitButton: some View {
        Button(action: submitBooking) {
            if isSubmitting {
                ProgressView()
                    .padding()
            } else {
                Text("Submit Booking")
                    .font(AppStyle.Fonts.vollkornBold(18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppStyle.Colors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
        }
        .disabled(isSubmitting)
        .padding(.horizontal)
    }

    // MARK: - Logic

    private func submitBooking() {
        guard !viewModel.selectedServiceIds.isEmpty else {
            viewModel.errorMessage = "Please select at least one service."
            return
        }

        isSubmitting = true
        viewModel.errorMessage = nil
        let group = DispatchGroup()
        var hasError = false

        for serviceId in viewModel.selectedServiceIds {
            group.enter()
            viewModel.createBooking(serviceId: serviceId) { success in
                if !success { hasError = true }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            isSubmitting = false
            if hasError {
                viewModel.errorMessage = "Failed to create one or more bookings."
            } else {
                viewModel.isNotedActive = false
                viewModel.isDateSelectionActive = false
                viewModel.isBookingActive = false
            }
        }
    }
}
////////////////////////////////////
