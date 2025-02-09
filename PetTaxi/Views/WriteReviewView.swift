import SwiftUI

struct WriteReviewView: View {
    @ObservedObject var viewModel: PostDetailViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Write a Review")
                .font(.custom("Vollkorn-Bold", size: 20))
                .foregroundColor(.black)
            
            TextEditor(text: $viewModel.newReviewText)
                .frame(height: 100)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                viewModel.submitReview()
                isPresented = false
            }) {
                Text("Submit Review")
                    .font(.custom("Vollkorn-Bold", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
