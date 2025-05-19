import SwiftUI

struct PostView: View {
    let post: Post
    
    var body: some View {
        NavigationStack {
            NavigationLink(destination: PostDetailView(post: post, viewModel: BookingViewModel(animalType: post.animalType), reviewViewModel: PostDetailViewModel(post: post))) {
                VStack(alignment: .leading, spacing: 12) {
                    if let firstImageUrl = post.imagesUrl?.first, let url = URL(string: firstImageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                            case .failure:
                                randomDefaultImage
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        randomDefaultImage
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(post.user?.username ?? "Unknown User")
                                .font(.custom("Vollkorn-Bold", size: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                    if let location = post.location?.name {
                                        Text(location)
                                            .font(.custom("Vollkorn-Medium", size: 14))
                                            .foregroundColor(.color3)
                                            .padding(4)
                                            .background(Color.color3.opacity(0.15))
                                            .cornerRadius(6)
                                    }

                                    Text(post.animalType.capitalized)
                                        .font(.custom("Vollkorn-Medium", size: 14))
                                        .padding(6)
                                        .background(Color.color3.opacity(0.3))
                                        .cornerRadius(10)
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(post.services, id: \.id) { service in
                                Text("\(service.serviceType.capitalized) ($\(service.price, specifier: "%.2f"))")
                                    .font(.custom("Vollkorn-Medium", size: 14))
                                    .padding(6)
                                    .background(Color.color3.opacity(0.3))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        HStack {
                            ForEach(post.animalSizes, id: \.self) { size in
                                Text(size.capitalized)
                                    .font(.custom("Vollkorn-Medium", size: 14))
                                    .padding(6)
                                    .background(Color.color.opacity(0.3))
                                    .cornerRadius(10)
                            }
                        }
                        
                        Text(post.description)
                            .font(.custom("Vollkorn", size: 14))
                            .lineLimit(3)
                            .truncationMode(.tail)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
            }
        }
    }
    
    private var randomDefaultImage: some View {
        let defaultImages = ["def1", "def2", "def3", "def4", "def5"]
        let randomImage = defaultImages.randomElement() ?? "def1"
        return Image(randomImage)
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
    }
}
