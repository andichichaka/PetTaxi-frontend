//
//  PostDetailView.swift
//  PetTaxi
//
//  Created by Andrey on 28.12.24.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Image Carousel
                TabView {
                    ForEach(post.imagesUrl!, id: \.self) { imageUrl in
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
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 300)
                                        .foregroundColor(.gray)
                                        .background(Color.yellow.opacity(0.2))
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
                        .foregroundColor(.secondary)

                    // "Book Now" Button
                    Button(action: {
                        print("Book Now tapped")
                    }) {
                        Text("Book Now")
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
        .background(LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all))
        .navigationTitle("Service Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
