import SwiftUI

struct WriteReviewView: View {
    @ObservedObject var viewModel: PostDetailViewModel
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 16) {
            header
            reviewInput
            errorSection
            submitButton
        }
        .padding()
        .background(AppStyle.Colors.light)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    // MARK: - Subviews

    private var header: some View {
        Text("Write a Review")
            .font(AppStyle.Fonts.vollkornBold(20))
            .foregroundColor(.black)
    }

    private var reviewInput: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.newReviewText.isEmpty {
                Text("Share your experience...")
                    .foregroundColor(.gray)
                    .padding(.top, 12)
                    .padding(.leading, 6)
                    .font(AppStyle.Fonts.vollkornRegular(16))
            }

            TextEditor(text: $viewModel.newReviewText)
                .font(AppStyle.Fonts.vollkornRegular(16))
                .padding(8)
                .frame(minHeight: 100)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
    }

    private var errorSection: some View {
        Group {
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(AppStyle.Fonts.vollkornMedium(14))
            }
        }
    }

    private var submitButton: some View {
        Button {
            viewModel.submitReview()
            isPresented = false
        } label: {
            Text("Submit Review")
                .font(AppStyle.Fonts.vollkornBold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppStyle.Colors.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
    }
}
