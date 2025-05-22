import SwiftUI

struct PostView: View {
    let post: Post

    var body: some View {
        NavigationStack {
            NavigationLink(destination: PostDetailView(
                post: post,
                viewModel: BookingViewModel(animalType: post.animalType),
                reviewViewModel: PostDetailViewModel(post: post)
            )) {
                postCard
            }
        }
    }

    // MARK: - Card UI

    private var postCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            postImage
            postContent
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    private var postImage: some View {
        Group {
            if let urlString = post.imagesUrl?.first, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView().frame(height: 200)
                    case .success(let image): image.resizable().scaledToFill().frame(height: 200).clipped()
                    case .failure: randomDefaultImage
                    @unknown default: EmptyView()
                    }
                }
            } else {
                randomDefaultImage
            }
        }
    }

    private var postContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            userHeader
            serviceList
            animalSizeList
            postDescription
        }
        .padding()
    }

    private var userHeader: some View {
        HStack {
            Text(post.user?.username ?? "Unknown User")
                .font(AppStyle.Fonts.vollkornBold(16))
                .foregroundColor(.black)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let location = post.location?.name {
                    Text(location)
                        .font(AppStyle.Fonts.vollkornMedium(14))
                        .foregroundColor(AppStyle.Colors.accent)
                        .padding(4)
                        .background(AppStyle.Colors.accent.opacity(0.15))
                        .cornerRadius(6)
                }

                Text(post.animalType.capitalized)
                    .font(AppStyle.Fonts.vollkornMedium(14))
                    .padding(6)
                    .background(AppStyle.Colors.accent.opacity(0.3))
                    .cornerRadius(10)
            }
        }
    }

    private var serviceList: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(post.services, id: \.id) { service in
                Text("\(service.serviceType.capitalized) ($\(service.price, specifier: "%.2f"))")
                    .font(AppStyle.Fonts.vollkornMedium(14))
                    .padding(6)
                    .background(AppStyle.Colors.accent.opacity(0.3))
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 4)
    }

    private var animalSizeList: some View {
        HStack {
            ForEach(post.animalSizes, id: \.self) { size in
                Text(size.capitalized)
                    .font(AppStyle.Fonts.vollkornMedium(14))
                    .padding(6)
                    .background(AppStyle.Colors.base.opacity(0.3))
                    .cornerRadius(10)
            }
        }
    }

    private var postDescription: some View {
        Text(post.description)
            .font(AppStyle.Fonts.vollkornRegular(14))
            .foregroundColor(.black.opacity(0.7))
            .lineLimit(3)
            .truncationMode(.tail)
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
