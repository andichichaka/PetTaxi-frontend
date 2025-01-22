//
//  NavigationBarView.swift
//  PetTaxi
//
//  Created by Andrey on 2.01.25.
//

import SwiftUI

struct NavigationBarView: View {
    @State private var selectedTab: Tab = .home
    @State private var isCreatePostActive: Bool = false
    @StateObject private var roleManager = RoleManager()
    
    enum Tab {
        case home
        case profile
        case createPost
    }
    
    var body: some View {
        NavigationStack{
            TabView(selection: $selectedTab) {
                HomePageView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(Tab.home)
                
                if roleManager.userRole == "admin" {
                    Button(action: {
                        isCreatePostActive = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.yellow)
                            .padding()
                            .background(Circle().fill(Color.white).shadow(radius: 4))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .offset(y: -20)
                    .fullScreenCover(isPresented: $isCreatePostActive) {
                        CreatePostView(isActive: $isCreatePostActive)
                    }
                    .tabItem{
                        Image(systemName: "plus.circle.fill")
                        Text("Create Post")
                    }
                    .tag(Tab.createPost)
                }
                
                ProfilePage()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(Tab.profile)
            }
        }
    }
}
