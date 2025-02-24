import SwiftUI
import Combine

struct PostDetailView: View {
    let post: Post
    @ObservedObject var viewModel: BookingViewModel =  BookingViewModel(animalType: "")
    @StateObject var reviewViewModel: PostDetailViewModel = PostDetailViewModel(post: Post(id: -1, description: "", animalType: "", animalSizes: [], user: User(id: -1, access_token: "", refresh_token: "", email: "", username: "", role: "", description: "", profilePic: "", isEmailVerified: false ), services: [], reviews: []))
    @State private var isWritingReview: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                imageCarouselSection

                postDetailsSection

                reviewsSection
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.color3.opacity(0.2), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)
        )
        .navigationTitle("Service Details")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $viewModel.isBookingActive) {
            BookingView(
                viewModel: viewModel,
                availableServices: post.services,
                unavailableDates: collectUnavailableDates(for: post.services),
                availableAnimalSizes: post.animalSizes,
                animalType: post.animalType,
                isActive: $viewModel.isBookingActive
            )
        }
    }

    // MARK: - Subviews

    private var imageCarouselSection: some View {
        Group {
            if post.imagesUrl?.isEmpty ?? true {
                randomDefaultImage
                    .frame(height: 300)
                    .clipped()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.horizontal)
            } else {
                TabView {
                    ForEach(post.imagesUrl ?? [], id: \.self) { imageUrl in
                        if let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(height: 300)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 300)
                                        .clipped()
                                case .failure:
                                    randomDefaultImage
                                        .frame(height: 300)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            randomDefaultImage
                                .frame(height: 300)
                        }
                    }
                }
                .frame(height: 300)
                .tabViewStyle(PageTabViewStyle())
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
            }
        }
    }

    private var postDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(post.user?.username ?? "Unknown User")
                    .font(.custom("Vollkorn-Bold", size: 20))
                    .foregroundColor(.black)

                Spacer()

                Text(post.animalType.capitalized)
                    .font(.custom("Vollkorn-Medium", size: 16))
                    .padding(6)
                    .background(Color.color3.opacity(0.3))
                    .cornerRadius(10)
            }

            servicesAndSizesSection

            Text(post.description)
                .font(.custom("Vollkorn-Regular", size: 16))
                .foregroundColor(.black.opacity(0.7))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: {
                viewModel.isBookingActive = true
            }) {
                Text("Request Booking Now")
                    .font(.custom("Vollkorn-Bold", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.color2)
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

    private var servicesAndSizesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Services")
                .font(.custom("Vollkorn-Bold", size: 18))
                .foregroundColor(.black)

            ForEach(post.services, id: \.id) { service in
                HStack {
                    Text(service.serviceType.capitalized)
                        .font(.custom("Vollkorn-Medium", size: 16))
                        .foregroundColor(.black.opacity(0.8))

                    Spacer()

                    Text("$\(service.price, specifier: "%.2f")")
                        .font(.custom("Vollkorn-Medium", size: 16))
                        .foregroundColor(.black.opacity(0.6))
                }
                .padding(8)
                .background(Color.color2.opacity(0.3))
                .cornerRadius(10)
            }

            Text("Sizes")
                .font(.custom("Vollkorn-Bold", size: 18))
                .foregroundColor(.black)

            HStack {
                ForEach(post.animalSizes, id: \.self) { size in
                    Text(size.capitalized)
                        .font(.custom("Vollkorn-Medium", size: 16))
                        .padding(8)
                        .background(Color.color.opacity(0.3))
                        .foregroundColor(.black.opacity(0.8))
                        .cornerRadius(10)
                }
            }
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Client Reviews")
                .font(.custom("Vollkorn-Bold", size: 20))
                .foregroundColor(.black)

            let reviews = $reviewViewModel.reviews
            if !reviews.isEmpty {
                
                ForEach(reviews, id: \.id) { review in
                    HStack(alignment: .top, spacing: 12) {
                        if let profilePicUrl = review.user.wrappedValue.profilePic, let url = URL(string: profilePicUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                case .failure:
                                    defaultProfileIcon
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            defaultProfileIcon
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(review.user.wrappedValue.username)
                                .font(.custom("Vollkorn-Bold", size: 16))
                                .foregroundColor(.black)

                            Text(review.wrappedValue.comment)
                                .font(.custom("Vollkorn", size: 14))
                                .foregroundColor(.black.opacity(0.7))
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("No reviews yet. Be the first to leave a review!")
                    .font(.custom("Vollkorn", size: 14))
                    .foregroundColor(.black.opacity(0.7))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Button(action: { isWritingReview.toggle() }) {
                Text("Write a Review")
                    .font(.custom("Vollkorn-Bold", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.color2)
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
        .sheet(isPresented: $isWritingReview) {
            WriteReviewView(viewModel: reviewViewModel, isPresented: $isWritingReview)
        }
    }

    private var defaultProfileIcon: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.gray)
    }
    // MARK: - Helper Functions

    private var randomDefaultImage: some View {
        let defaultImages = ["def1", "def2", "def3", "def4", "def5"]
        let randomImage = defaultImages.randomElement() ?? "def1"
        return Image(randomImage)
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .clipped()
    }

    private func collectUnavailableDates(for services: [Service]) -> [Date] {
        let formatter = ISO8601DateFormatter()
        var unavailableDates: [Date] = []

        for service in services {
            let parsedDates = service.unavailableDates.compactMap { dateString -> Date? in
                return formatter.date(from: dateString ?? "")
            }
            unavailableDates.append(contentsOf: parsedDates)
        }

        return unavailableDates
    }
}
