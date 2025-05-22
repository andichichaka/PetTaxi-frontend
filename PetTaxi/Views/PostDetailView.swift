import SwiftUI
import Combine

struct PostDetailView: View {
    let post: Post
    @ObservedObject var viewModel: BookingViewModel = BookingViewModel(animalType: "")
    @StateObject var reviewViewModel: PostDetailViewModel = PostDetailViewModel(
        post: Post(id: -1, imagesUrl: [], description: "", animalType: "", animalSizes: [], user: User(id: -1, access_token: "", refresh_token: "", email: "", username: "", role: "", description: "", profilePic: "", isEmailVerified: false), location: nil, services: [], reviews: [])
    )
    @State private var isWritingReview = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                imageCarousel
                detailsSection
                reviewSection
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [AppStyle.Colors.accent.opacity(0.2), .white]),
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

    private var imageCarousel: some View {
        Group {
            if post.imagesUrl?.isEmpty ?? true {
                randomDefaultImage
            } else {
                TabView {
                    ForEach(post.imagesUrl ?? [], id: \.self) { url in
                        if let validURL = URL(string: url) {
                            AsyncImage(url: validURL) { phase in
                                switch phase {
                                case .empty: ProgressView().frame(height: 300)
                                case .success(let image): image.resizable().scaledToFill().frame(height: 300).clipped()
                                case .failure: randomDefaultImage
                                @unknown default: EmptyView()
                                }
                            }
                        } else {
                            randomDefaultImage
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
            }
        }
        .frame(height: 300)
        .background(.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            userHeader
            serviceAndSizeBlock
            descriptionBlock
            requestBookingButton
        }
        .padding()
        .background(.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    private var userHeader: some View {
        HStack {
            Text(post.user?.username ?? "Unknown User")
                .font(AppStyle.Fonts.vollkornBold(20))
                .foregroundColor(.black)
            Spacer()
            if let location = post.location?.name {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(AppStyle.Colors.accent)
                    Text(location)
                        .font(AppStyle.Fonts.vollkornMedium(16))
                        .foregroundColor(AppStyle.Colors.accent)
                }
                .padding(.top, -8)
            }
            Text(post.animalType.capitalized)
                .font(AppStyle.Fonts.vollkornMedium(16))
                .padding(6)
                .background(AppStyle.Colors.accent.opacity(0.3))
                .cornerRadius(10)
        }
    }

    private var serviceAndSizeBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Services")
                .font(AppStyle.Fonts.vollkornBold(18))
            ForEach(post.services, id: \.id) { service in
                HStack {
                    Text(service.serviceType.capitalized)
                        .font(AppStyle.Fonts.vollkornMedium(16))
                    Spacer()
                    Text("$\(service.price, specifier: "%.2f")")
                        .font(AppStyle.Fonts.vollkornMedium(16))
                        .foregroundColor(.black.opacity(0.6))
                }
                .padding(8)
                .background(AppStyle.Colors.secondary.opacity(0.3))
                .cornerRadius(10)
            }

            Text("Sizes")
                .font(AppStyle.Fonts.vollkornBold(18))

            HStack {
                ForEach(post.animalSizes, id: \.self) { size in
                    Text(size.capitalized)
                        .font(AppStyle.Fonts.vollkornMedium(16))
                        .padding(8)
                        .background(AppStyle.Colors.base.opacity(0.3))
                        .cornerRadius(10)
                }
            }
        }
    }

    private var descriptionBlock: some View {
        Text(post.description)
            .font(AppStyle.Fonts.vollkornRegular(16))
            .foregroundColor(.black.opacity(0.7))
            .fixedSize(horizontal: false, vertical: true)
    }

    private var requestBookingButton: some View {
        Button {
            viewModel.isBookingActive = true
        } label: {
            Text("Request Booking Now")
                .font(AppStyle.Fonts.vollkornBold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppStyle.Colors.secondary)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Client Reviews")
                .font(AppStyle.Fonts.vollkornBold(20))

            let reviews = $reviewViewModel.reviews
            if !reviews.isEmpty {
                ForEach(reviews, id: \.id) { review in
                    reviewRow(review: review)
                }
            } else {
                Text("No reviews yet. Be the first to leave a review!")
                    .font(AppStyle.Fonts.vollkornRegular(14))
                    .foregroundColor(.black.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Button("Write a Review") {
                isWritingReview = true
            }
            .font(AppStyle.Fonts.vollkornBold(18))
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppStyle.Colors.secondary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        .padding()
        .background(.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
        .sheet(isPresented: $isWritingReview) {
            WriteReviewView(viewModel: reviewViewModel, isPresented: $isWritingReview)
        }
    }

    private func reviewRow(review: Binding<Review>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if let url = URL(string: review.user.wrappedValue.profilePic ?? "") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let image): image.resizable().frame(width: 40, height: 40).clipShape(Circle())
                    case .failure: defaultProfileIcon
                    @unknown default: EmptyView()
                    }
                }
            } else {
                defaultProfileIcon
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(review.user.wrappedValue.username)
                    .font(AppStyle.Fonts.vollkornBold(16))
                Text(review.wrappedValue.comment)
                    .font(AppStyle.Fonts.vollkornRegular(14))
                    .foregroundColor(.black.opacity(0.7))
            }
        }
        .padding(.vertical, 4)
    }

    private var defaultProfileIcon: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.gray)
    }

    private var randomDefaultImage: some View {
        let defaultImages = ["def1", "def2", "def3", "def4", "def5"]
        let imageName = defaultImages.randomElement() ?? "def1"
        return Image(imageName)
            .resizable()
            .scaledToFill()
            .clipped()
    }

    private func collectUnavailableDates(for services: [Service]) -> [Date] {
        let formatter = ISO8601DateFormatter()
        return services.flatMap { $0.unavailableDates.compactMap { formatter.date(from: $0 ?? "") } }
    }
}
