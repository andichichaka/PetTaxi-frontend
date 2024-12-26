import SwiftUI

struct ContentView: View {
    @State private var isLogin = true

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer() // Push everything to the center

                    VStack(spacing: 20) {
                        // App Title
                        VStack(spacing: 8) {
                            Text("PetTaxi")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text("Your pets' reliable ride companion")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 20)

                        // Content Box
                        ZStack {
                            VStack(spacing: 20) {
                                // Toggle Buttons
                                HStack(spacing: 0) {
                                    Button(action: {
                                        isLogin = true
                                    }) {
                                        Text("Login")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(isLogin ? Color.yellow : Color.white)
                                            .foregroundColor(isLogin ? .white : .gray)
                                            .cornerRadius(10)
                                    }
                                    .shadow(radius: 3)

                                    Button(action: {
                                        isLogin = false
                                    }) {
                                        Text("Sign Up")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(!isLogin ? Color.yellow : Color.white)
                                            .foregroundColor(!isLogin ? .white : .gray)
                                            .cornerRadius(10)
                                    }
                                    .shadow(radius: 3)
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
                    }

                    Spacer() // Push everything to the center
                }
            }
        }
    }
}



#Preview{
    ContentView()
}
