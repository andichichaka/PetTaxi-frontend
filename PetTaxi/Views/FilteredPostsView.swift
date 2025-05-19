import SwiftUI

struct FilteredPostsView: View {
    @Binding var isActive: Bool
    @ObservedObject var viewModel: SearchFilterViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                LiveBlurryBackground()
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 16) {
                        Spacer().frame(height: 120)

                        if viewModel.filteredPosts.isEmpty {
                            noResultsText
                        } else {
                            ForEach(viewModel.filteredPosts) { post in
                                PostView(post: post)
                            }
                        }
                    }
                    .padding(.vertical)
                }

                topBar
            }
        }
    }

    // MARK: - Subviews

    private var topBar: some View {
        VStack {
            HStack {
                Button(action: { isActive = false }) {
                    Image(systemName: "arrow.backward")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.trailing, 8)
                }

                Text("Search Results")
                    .font(AppStyle.Fonts.lilita(28))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.7))
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.top, 5)
            .zIndex(1)

            Spacer()
        }
    }

    private var noResultsText: some View {
        Text("No posts match your filters.")
            .font(AppStyle.Fonts.vollkornMedium(18))
            .foregroundColor(.white)
            .padding()
    }
}

#Preview {
    FilteredPostsView(
        isActive: .constant(true),
        viewModel: SearchFilterViewModel()
    )
}
