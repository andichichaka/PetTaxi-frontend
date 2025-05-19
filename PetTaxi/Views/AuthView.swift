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
                    authCard
                    Spacer()
                }
            }
        }
    }

    // MARK: - Auth Card

    private var authCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppStyle.Colors.light.opacity(0.2))
                .background(.ultraThinMaterial)
                .cornerRadius(50)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

            VStack(spacing: 0) {
                headerSection
                tabButtons
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
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: -20) {
                Text("PetTaxi")
                    .font(AppStyle.Fonts.lilita(60))
                    .fontWeight(.bold)
                    .foregroundColor(AppStyle.Colors.light)

                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 90)
            }

            Text("Your pets' reliable companion")
                .font(AppStyle.Fonts.vollkornBoldItalic(21))
                .foregroundColor(AppStyle.Colors.light.opacity(0.9))
        }
        .padding(.bottom, 20)
    }

    // MARK: - Tab Buttons

    private var tabButtons: some View {
        HStack(spacing: 0) {
            authTabButton(title: "Login", isActive: isLogin) {
                isLogin = true
            }
            authTabButton(title: "Sign Up", isActive: !isLogin) {
                isLogin = false
            }
        }
        .padding(.horizontal)
    }

    private func authTabButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppStyle.Fonts.vollkornSemibold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(isActive ? AppStyle.Colors.accent : Color.clear)
                .foregroundColor(isActive ? AppStyle.Colors.light : AppStyle.Colors.light.opacity(0.7))
                .cornerRadius(10)
        }
    }
}

#Preview {
    AuthView()
}
