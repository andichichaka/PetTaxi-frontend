import SwiftUI

struct RequestedBookingsView: View {
    @StateObject private var viewModel = RequestedBookingsViewModel()
    private let roleManager = RoleManager()

    var body: some View {
        NavigationStack {
            ZStack {
                LiveBlurryBackground()
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .font(.custom("Vollkorn-Bold", size: 18))
                        .foregroundColor(.color)
                } else if viewModel.bookings.isEmpty {
                    Text(roleManager.userRole == "admin" ? "No requested bookings." : "No approved bookings.")
                        .font(.custom("Vollkorn-Medium", size: 16))
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
            .navigationTitle("Requested Bookings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchBookings()
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
            HStack {
                if let profilePicture = booking.user.profilePic {
                    AsyncImage(url: URL(string: profilePicture)) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                }
                
                Text(booking.user.username)
                    .font(.custom("Vollkorn-Bold", size: 18))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Service: \(booking.service.serviceType.capitalized)")
                Text("Animal: \(booking.animalType) (\(booking.animalSize))")
                Text("Dates: \(booking.bookingDates.joined(separator: ", "))")
                Text("Price: $\(booking.price, specifier: "%.2f")")
                Text("Notes: \(booking.notes)")
            }
            .font(.custom("Vollkorn-Regular", size: 16))
            .foregroundColor(.black)
            
            Divider()
            
            HStack {
                if let postImageURL = booking.service.post?.imagesUrl?.first,
                   let postId = booking.service.post?.id {
                    NavigationLink(destination: PostDetailView(post: booking.service.post!)) {
                        AsyncImage(url: URL(string: postImageURL)) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "photo")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                Text("Post: \(booking.service.post?.description ?? "Unknown")")
                    .font(.custom("Vollkorn-Medium", size: 14))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            if roleManager.userRole == "admin" {
                HStack {
                    Button(action: {
                        viewModel.approveBooking(booking.id)
                    }) {
                        Text("Approve")
                            .font(.custom("Vollkorn-Bold", size: 16))
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
                            .font(.custom("Vollkorn-Bold", size: 16))
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
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
