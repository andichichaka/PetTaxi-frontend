import SwiftUI

struct FilteredPostsView: View {
    @Binding var isActive: Bool
    @ObservedObject var viewModel: SearchFilterViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Live Blurry Background
                LiveBlurryBackground()
                    .edgesIgnoringSafeArea(.all)

                // Post List (Scrolls behind the top bar)
                ScrollView {
                    VStack(spacing: 16) {
                        // Add padding to the top to account for the floating top bar
                        Spacer()
                            .frame(height: 120) // Adjust this value to match the top bar height

                        // Posts
                        if viewModel.filteredPosts.isEmpty {
                            Text("No posts match your filters.")
                                .font(.custom("Vollkorn-Medium", size: 18)) // Custom Font
                                .foregroundColor(.white)
                                .padding()
                        } else {
                            ForEach(viewModel.filteredPosts) { post in
                                PostView(post: post)
                            }
                        }
                    }
                    .padding(.vertical)
                }

                // Floating Top Bar
                VStack {
                    HStack {
                        // Back Button
                        Button(action: {
                            isActive = false
                        }) {
                            Image(systemName: "arrow.backward")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.trailing, 8)
                        }

                        // Title
                        Text("Search Results")
                            .font(.custom("LilitaOne", size: 28)) // Custom Font
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.top, 5)
                    .zIndex(1) // Ensure the top bar stays above the posts

                    Spacer() // Push the top bar to the top
                }
            }
        }
    }
}

#Preview {
    FilteredPostsView(
        isActive: .constant(true),
        viewModel: SearchFilterViewModel()
    )
}
