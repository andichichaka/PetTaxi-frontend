////
////  PostView.swift
////  PetTaxi
////
////  Created by Andrey on 27.12.24.
////
//
import SwiftUI
//
//struct PostView: View {
//    let post: Post
//
//    var body: some View {
//        NavigationLink(destination: PostDetailView(post: post)) {
//            VStack(alignment: .leading, spacing: 12) {
//                // Image or Placeholder
//                if let firstImageUrl = post.imagesUrl?.first, let url = URL(string: firstImageUrl) {
//                    AsyncImage(url: url) { phase in
//                        switch phase {
//                        case .empty:
//                            ProgressView()
//                                .frame(height: 200)
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .scaledToFill()
//                                .frame(height: 200)
//                                .clipped()
//                        case .failure:
//                            placeholderImage
//                        @unknown default:
//                            EmptyView()
//                        }
//                    }
//                } else {
//                    placeholderImage
//                }
//
//                // Post Content
//                VStack(alignment: .leading, spacing: 8) {
//                    HStack{
//                        Text(post.user.username)
//                            .font(.headline)
//                        
//                        Text(post.animalType)
//                            .font(.subheadline)
//                            .padding(6)
//                            .background(Color.green.opacity(0.3))
//                            .cornerRadius(10)
//                            .frame(alignment: .trailing)
//                    }
//
//                    // Services & Sizes
//                    servicesAndSizesSection
//
//                    Text(post.description)
//                        .font(.body)
//                        .lineLimit(2)
//                        .foregroundColor(.secondary)
//                }
//                .padding()
//            }
//            .frame(maxWidth: .infinity) // Consistent width
//            .background(Color.white) // Background for each post
//            .cornerRadius(15)
//            .shadow(radius: 5)
//            .padding(.horizontal)
//        }
//    }
//
//    private var placeholderImage: some View {
//        Image(systemName: "photo")
//            .resizable()
//            .scaledToFit()
//            .frame(height: 200)
//            .foregroundColor(.gray)
//            .background(Color.yellow.opacity(0.2))
//    }
//
//    private var servicesAndSizesSection: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            HStack {
//                ForEach(post.services, id: \.self) { service in
//                    Text(service.serviceType)
//                        .font(.subheadline)
//                        .padding(6)
//                        .background(Color.yellow.opacity(0.3))
//                        .cornerRadius(10)
//                }
//            }
//            .lineLimit(1) // Keep one row for services
//
//            HStack {
//                ForEach(post.animalSizes, id: \.self) { size in
//                    Text(size)
//                        .font(.subheadline)
//                        .padding(6)
//                        .background(Color.blue.opacity(0.3))
//                        .cornerRadius(10)
//                }
//            }
//            .lineLimit(1) // Keep one row for sizes
//        }
//    }
//}

struct PostView: View {
    let post: Post

    var body: some View {
        NavigationLink(destination: PostDetailView(post: post)) {
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
                            placeholderImage
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    placeholderImage
                }

                // Post Content
                VStack(alignment: .leading, spacing: 8) {
                    // User and Animal Type
                    HStack {
                        Text(post.user.username)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(post.animalType.capitalized)
                            .font(.subheadline)
                            .padding(6)
                            .background(Color.green.opacity(0.3))
                            .cornerRadius(10)
                    }

                    // Services & Sizes
                    servicesAndSizesSection

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

    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(height: 200)
            .foregroundColor(.gray)
            .background(Color.yellow.opacity(0.2))
    }

    private var servicesAndSizesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                ForEach(post.services, id: \.id) { service in
                    Text("\(service.serviceType.capitalized) ($\(service.price, specifier: "%.2f"))")
                        .font(.subheadline)
                        .padding(6)
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(10)
                }
            }
            .lineLimit(1) // Keep one row for services

            HStack {
                ForEach(post.animalSizes, id: \.self) { size in
                    Text(size.capitalized)
                        .font(.subheadline)
                        .padding(6)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(10)
                }
            }
            .lineLimit(1) // Keep one row for sizes
        }
    }
}

