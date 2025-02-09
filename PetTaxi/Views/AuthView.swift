import SwiftUI

struct AuthView: View {
    @State private var isLogin = true

    var body: some View {
        NavigationStack {
            ZStack {
                DarkGreenBubbleBackground()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.2))
                            .background(.ultraThinMaterial)
                            .cornerRadius(50)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

                        VStack(spacing: 0) {
                            VStack(spacing: 0) {
                                HStack(alignment: .center, spacing: -20) {
                                    Text("PetTaxi")
                                        .font(.custom("LilitaOne", size: 60))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)

                                    Image("AppLogo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 90)
                                }

                                Text("Your pets' reliable companion")
                                    .font(.custom("Vollkorn-BoldItalic", size: 21))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.bottom, 20)

                            HStack(spacing: 0) {
                                Button(action: {
                                    isLogin = true
                                }) {
                                    Text("Login")
                                        .font(.custom("Vollkorn-SemiBold", size: 18))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(isLogin ? Color.color3 : Color.clear)
                                        .foregroundColor(isLogin ? .white : .white.opacity(0.7))
                                        .cornerRadius(10)
                                }

                                Button(action: {
                                    isLogin = false
                                }) {
                                    Text("Sign Up")
                                        .font(.custom("Vollkorn-SemiBold", size: 18))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(!isLogin ? Color.color3 : Color.clear)
                                        .foregroundColor(!isLogin ? .white : .white.opacity(0.7))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)

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

struct DarkGreenBubbleBackground: View {
    @State private var bubbleOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color(red: 0, green: 100/255, blue: 0, opacity: 0.8)
                .edgesIgnoringSafeArea(.all)

            ForEach(0..<20) { _ in
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: CGFloat.random(in: 50..<120), height: CGFloat.random(in: 50..<120))
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
        .blur(radius: 10)
        .onAppear {
            bubbleOffset = 20
        }
    }
}

#Preview {
    AuthView()
}
