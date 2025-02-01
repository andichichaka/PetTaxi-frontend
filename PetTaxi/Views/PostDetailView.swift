import SwiftUI
import Combine

struct PostDetailView: View {
    let post: Post
    @ObservedObject var viewModel: BookingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Image Carousel
                imageCarouselSection

                // Post Details
                postDetailsSection

                // Reviews Section
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

    // Image Carousel Section
    private var imageCarouselSection: some View {
        Group {
            if post.imagesUrl?.isEmpty ?? true {
                // If no images, show a single default image
                randomDefaultImage
                    .frame(height: 300)
                    .clipped()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.horizontal)
            } else {
                // If images exist, show the carousel
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

    // Post Details Section
    private var postDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // User and Animal Type
            HStack {
                Text(post.user?.username ?? "Unknown User")
                    .font(.custom("Vollkorn-Bold", size: 20))
                    .foregroundColor(.black)

                Spacer()

                Text(post.animalType.capitalized)
                    .font(.custom("Vollkorn-Medium", size: 16))
                    .padding(6)
                    .background(Color.color3.opacity(0.3)) // Mint Green
                    .cornerRadius(10)
            }

            // Services and Sizes
            servicesAndSizesSection

            // Description
            Text(post.description)
                .font(.custom("Vollkorn-Regular", size: 16))
                .foregroundColor(.black.opacity(0.7))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            // "Request Booking Now" Button
            Button(action: {
                viewModel.isBookingActive = true
            }) {
                Text("Request Booking Now")
                    .font(.custom("Vollkorn-Bold", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.color2) // Light Green
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

    // Services and Sizes Section
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
                .background(Color.color2.opacity(0.3)) // Light Green
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
                        .background(Color.color.opacity(0.3)) // Dark Green
                        .foregroundColor(.black.opacity(0.8))
                        .cornerRadius(10)
                }
            }
        }
    }

    // Reviews Section
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Client Reviews")
                .font(.custom("Vollkorn-Bold", size: 20))
                .foregroundColor(.black)

            ForEach(0..<2, id: \.self) { _ in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Jane Cooper")
                            .font(.custom("Vollkorn-Bold", size: 16))
                            .foregroundColor(.black)

                        Text("Excellent service! Very professional and caring with my pets.")
                            .font(.custom("Vollkorn", size: 14))
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    // Random Default Image
    private var randomDefaultImage: some View {
        let defaultImages = ["def1", "def2", "def3", "def4", "def5"]
        let randomImage = defaultImages.randomElement() ?? "def1"
        return Image(randomImage)
            .resizable()
            .scaledToFill()
            .frame(height: 300)
            .clipped()
    }

    // Helper Function to Collect Unavailable Dates
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
