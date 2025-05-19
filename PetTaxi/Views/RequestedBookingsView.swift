import SwiftUI

struct RequestedBookingsView: View {
    @StateObject private var viewModel = RequestedBookingsViewModel()
    private let roleManager = RoleManager()

    var body: some View {
        NavigationStack {
            ZStack {
                LiveBlurryBackground()

                content
            }
            .navigationTitle("Requested Bookings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchBookings()
            }
        }
    }

    private var content: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .font(AppStyle.Fonts.vollkornBold(18))
                    .foregroundColor(AppStyle.Colors.base)
            } else if viewModel.bookings.isEmpty {
                Text(roleManager.userRole == "admin" ? "No requested bookings." : "No approved bookings.")
                    .font(AppStyle.Fonts.vollkornMedium(16))
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.bookings, id: \.id) { booking in
                            BookingRequestCard(booking: booking, viewModel: viewModel)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct BookingRequestCard: View {
    let booking: Booking
    @ObservedObject var viewModel: RequestedBookingsViewModel
    private let roleManager = RoleManager()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            userHeader
            Divider()
            bookingInfo
            Divider()
            postPreview
            if roleManager.userRole == "admin" {
                adminActions
            }
        }
        .padding()
        .background(AppStyle.Colors.light.opacity(0.8))
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    private var userHeader: some View {
        HStack {
            if let profilePicture = booking.user.profilePic,
               let url = URL(string: profilePicture) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                    default:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            }

            Text(booking.user.username)
                .font(AppStyle.Fonts.vollkornBold(18))
                .foregroundColor(.black)

            Spacer()
        }
    }

    private var bookingInfo: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Service: \(booking.service.serviceType.capitalized)")
            Text("Animal: \(booking.animalType) (\(booking.animalSize))")
            Text("Dates: \(booking.bookingDates.joined(separator: ", "))")
            Text("Price: $\(booking.price, specifier: "%.2f")")
            Text("Notes: \(booking.notes)")
        }
        .font(AppStyle.Fonts.vollkornRegular(16))
        .foregroundColor(.black)
    }

    private var postPreview: some View {
        HStack {
            if let imageURL = booking.service.post?.imagesUrl?.first,
               let url = URL(string: imageURL),
               let post = booking.service.post {
                NavigationLink(destination: PostDetailView(post: post)) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                        default:
                            Image(systemName: "photo")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            Text("Post: \(booking.service.post?.description ?? "Unknown")")
                .font(AppStyle.Fonts.vollkornMedium(14))
                .foregroundColor(.black)

            Spacer()
        }
    }

    private var adminActions: some View {
        HStack(spacing: 10) {
            Button(action: {
                viewModel.approveBooking(booking.id)
            }) {
                Text("Approve")
                    .font(AppStyle.Fonts.vollkornBold(16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }

            Button(action: {
                viewModel.disapproveBooking(booking.id)
            }) {
                Text("Disapprove")
                    .font(AppStyle.Fonts.vollkornBold(16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
        }
    }
}
