//
//  PostView.swift
//  PetTaxi
//
//  Created by Andrey on 27.12.24.
//

import SwiftUI

struct PostView: View {
    let post: Post

    var body: some View {
        NavigationLink(destination: PostDetailView(post: post)) {
            VStack(alignment: .leading, spacing: 8) {
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
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.gray)
                                .background(Color.yellow.opacity(0.2))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .foregroundColor(.gray)
                        .background(Color.yellow.opacity(0.2))
                }

                // Post Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.user.username)
                        .font(.headline)

                    HStack {
                        Text(post.serviceType)
                            .font(.subheadline)
                            .padding(6)
                            .background(Color.yellow.opacity(0.3))
                            .cornerRadius(10)

                        Text("\(post.animalType) • \(post.animalSize)")
                            .font(.subheadline)
                            .padding(6)
                            .background(Color.yellow.opacity(0.3))
                            .cornerRadius(10)
                    }

                    Text(post.description)
                        .font(.body)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
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
