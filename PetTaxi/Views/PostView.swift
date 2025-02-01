////
////  PostView.swift
////  PetTaxi
////
////  Created by Andrey on 27.12.24.
////
//
import SwiftUI

struct PostView: View {
    let post: Post
    
    var body: some View {
        NavigationStack {
            NavigationLink(destination: PostDetailView(post: post, viewModel: BookingViewModel(animalType: post.animalType))) {
                VStack(alignment: .leading, spacing: 12) {
                    // Image or Placeholder
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
                    
                    // Post Content
                    VStack(alignment: .leading, spacing: 8) {
                        // User and Animal Type
                        HStack {
                            Text(post.user?.username ?? "Unknown User")
                                .font(.custom("Vollkorn-Bold", size: 16)) // Custom Font
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text(post.animalType.capitalized)
                                .font(.custom("Vollkorn-Medium", size: 14)) // Custom Font
                                .padding(6)
                                .background(Color.color3.opacity(0.3)) // Mint Green
                                .cornerRadius(10)
                        }
                        
                        // Services (Vertical List)
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(post.services, id: \.id) { service in
                                Text("\(service.serviceType.capitalized) ($\(service.price, specifier: "%.2f"))")
                                    .font(.custom("Vollkorn-Medium", size: 14)) // Custom Font
                                    .padding(6)
                                    .background(Color.color3.opacity(0.3)) // Light Green
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Animal Sizes
                        HStack {
                            ForEach(post.animalSizes, id: \.self) { size in
                                Text(size.capitalized)
                                    .font(.custom("Vollkorn-Medium", size: 14)) // Custom Font
                                    .padding(6)
                                    .background(Color.color.opacity(0.3)) // Dark Green
                                    .cornerRadius(10)
                            }
                        }
                        
                        // Description (Truncated to 3 Lines)
                        Text(post.description)
                            .font(.custom("Vollkorn", size: 14)) // Custom Font
                            .lineLimit(3) // Truncate to 3 lines
                            .truncationMode(.tail) // Add ... at the end
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity) // Consistent width
                .background(Color.white) // Background for each post
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
            }
        }
    }
    
    // Random Default Image
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
