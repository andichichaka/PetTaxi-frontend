import SwiftUI

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Image Carousel
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
                                    placeholderImage
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
                .frame(height: 300)
                .tabViewStyle(PageTabViewStyle())

                // Post Content
                VStack(alignment: .leading, spacing: 16) {
                    Text(post.user.username)
                        .font(.title2)
                        .bold()

                    servicesAndSizesSection

                    Text(post.description)
                        .font(.body)
                        .foregroundColor(.secondary)

                    // "Request Booking Now" Button
                    NavigationLink(
                        destination: BookingView(
                            viewModel: BookingViewModel(),
                            services: post.services,
                            unavailableDates: collectUnavailableDates(for: post.services)
                        )
                    ) {
                        Text("Request Booking Now")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
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

                // Static Reviews
                reviewsSection
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)
        )
        .navigationTitle("Service Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func collectUnavailableDates(for services: [Service]) -> [Date] {
        let formatter = ISO8601DateFormatter()
        var unavailableDates: [Date] = []

        for service in services {
            // Properly handle optional `unavailableDates`
            let parsedDates = service.unavailableDates.compactMap { dateString -> Date? in
                return formatter.date(from: dateString ?? "")
            } ?? []

            unavailableDates.append(contentsOf: parsedDates)
        }

        return unavailableDates
    }

    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(height: 300)
            .foregroundColor(.gray)
            .background(Color.yellow.opacity(0.2))
    }

    private var servicesAndSizesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Services")
                .font(.headline)

            ForEach(post.services, id: \.id) { service in
                HStack {
                    Text(service.serviceType.capitalized)
                        .font(.subheadline)

                    Spacer()

                    Text("$\(service.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(6)
                .background(Color.yellow.opacity(0.3))
                .cornerRadius(10)
            }

            Text("Sizes")
                .font(.headline)

            HStack {
                ForEach(post.animalSizes, id: \.self) { size in
                    Text(size.capitalized)
                        .font(.subheadline)
                        .padding(6)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(10)
                }
            }
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Client Reviews")
                .font(.title3)
                .bold()

            ForEach(0..<2, id: \.self) { _ in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Jane Cooper")
                            .font(.headline)

                        Text("Excellent service! Very professional and caring with my pets.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
}
