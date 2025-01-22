//
//  FilteredPostsView.swift
//  PetTaxi
//
//  Created by Andrey on 16.01.25.
//

//
//  FilteredPostsView.swift
//  PetTaxi
//
//  Created by Andrey on 16.01.25.
//

import SwiftUI

struct FilteredPostsView: View {
    @Binding var isActive: Bool
    @ObservedObject var viewModel: SearchFilterViewModel

    var body: some View {
        NavigationStack{
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        Button(action: {
                            isActive = false
                        }) {
                            Image(systemName: "arrow.backward")
                                .font(.title2)
                                .padding(.trailing, 8)
                        }
                        
                        Text("Search Results")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    
                    // Results Content
                    if viewModel.filteredPosts.isEmpty {
                        VStack {
                            Spacer()
                            Text("No posts match your filters.")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(viewModel.filteredPosts) { post in
                                    PostView(post: post)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
        }
    }
}
