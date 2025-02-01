import SwiftUI

struct ContentView: View {
    @State private var isLogin = true

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark Green Background with Bigger Bubbles and Blur
                DarkGreenBubbleBackground()
                    .edgesIgnoringSafeArea(.all)

                // Translucent Box with Content
                VStack {
                    Spacer()

                    ZStack {
                        // Background Blur
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.2))
                            .background(.ultraThinMaterial) // Blur effect
                            .cornerRadius(50)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

                        VStack(spacing: 0) {
                            // App Logo and Title (HStack for logo and title, VStack for subtitle)
                            VStack(spacing: 0) {
                                // HStack for PetTaxi and AppLogo
                                HStack(alignment: .center, spacing: -20) {
                                    Text("PetTaxi")
                                        .font(.custom("LilitaOne", size: 60)) // Adjusted size
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)

                                    Image("AppLogo") // Use the logo from Assets.xcassets
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 90) // Adjust size as needed
                                }

                                // Subtitle
                                Text("Your pets' reliable companion")
                                    .font(.custom("Vollkorn-BoldItalic", size: 21)) // Adjusted size
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.bottom, 20)

                            // Toggle Buttons
                            HStack(spacing: 0) {
                                Button(action: {
                                    isLogin = true
                                }) {
                                    Text("Login")
                                        .font(.custom("Vollkorn-SemiBold", size: 18)) // Custom Font
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(isLogin ? Color.color3 : Color.clear) // Mint Green
                                        .foregroundColor(isLogin ? .white : .white.opacity(0.7))
                                        .cornerRadius(10)
                                }

                                Button(action: {
                                    isLogin = false
                                }) {
                                    Text("Sign Up")
                                        .font(.custom("Vollkorn-SemiBold", size: 18)) // Custom Font
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(!isLogin ? Color.color3 : Color.clear) // Mint Green
                                        .foregroundColor(!isLogin ? .white : .white.opacity(0.7))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)

                            // Conditional Views
                            if isLogin {
                                LogInView()
                            } else {
                                SignUpView()
                            }
                        }
                        .padding(20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
        }
    }
}

// Dark Green Background with Bigger Bubbles and Blur
struct DarkGreenBubbleBackground: View {
    @State private var bubbleOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Lighter Dark Green Background
            Color(red: 0, green: 100/255, blue: 0, opacity: 0.8) // Lighter Dark Green
                .edgesIgnoringSafeArea(.all)

            // Bigger Bubbles
            ForEach(0..<20) { _ in
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: CGFloat.random(in: 50..<120), height: CGFloat.random(in: 50..<120)) // Bigger Bubbles
                    .position(
                        x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
                    )
                    .offset(x: bubbleOffset, y: 0)
                    .animation(
                        Animation.easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: bubbleOffset
                    )
            }
        }
        .blur(radius: 10) // Blur the entire background
        .onAppear {
            bubbleOffset = 20 // Move bubbles slightly left and right
        }
    }
}

#Preview {
    ContentView()
}
