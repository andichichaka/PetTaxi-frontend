//
//  HomePageView.swift
//  PetTaxi
//
//  Created by Andrey on 24.12.24.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        VStack {
            Text("Welcome to PetTaxi!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("You have successfully logged in or signed up.")
                .font(.body)
                .foregroundColor(.gray)
                .padding()

            Spacer()
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
    }
}
