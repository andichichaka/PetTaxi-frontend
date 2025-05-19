import SwiftUI

struct RoleSelectionDialog: View {
    @Binding var isActive: Bool
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .onTapGesture { }

            VStack(spacing: 20) {
                header
                subheader
                roleOptions
                if let errorMessage = errorMessage {
                    errorMessageView(errorMessage)
                }
                if isSubmitting {
                    loadingView
                }
            }
            .padding()
            .background(AppStyle.Colors.light)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(30)
        }
        .ignoresSafeArea()
    }

    // MARK: - UI Components

    private var header: some View {
        Text("Choose Your Role")
            .font(AppStyle.Fonts.vollkornBold(25))
            .padding(.top)
            .padding(.bottom, -5)
    }

    private var subheader: some View {
        Text("Select how you'll be using our platform")
            .font(AppStyle.Fonts.vollkornMedium(17))
            .multilineTextAlignment(.center)
            .padding(.bottom)
    }

    private var roleOptions: some View {
        VStack(spacing: 16) {
            Button {
                submitRole("admin")
                UserDefaults.standard.set("admin", forKey: "userRole")
            } label: {
                RoleOptionView(
                    title: "Caretaker",
                    subtitle: "I want to provide pet care services",
                    icon: "heart.fill"
                )
            }

            Button {
                submitRole("user")
                UserDefaults.standard.set("user", forKey: "userRole")
            } label: {
                RoleOptionView(
                    title: "Regular User",
                    subtitle: "I am looking for pet care services",
                    icon: "person.fill"
                )
            }
        }
    }

    private func errorMessageView(_ message: String) -> some View {
        Text(message)
            .foregroundColor(.red)
            .font(.footnote)
            .padding(.top)
    }

    private var loadingView: some View {
        ProgressView("Submitting...")
            .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
            .padding()
    }

    // MARK: - Actions

    private func submitRole(_ role: String) {
        isSubmitting = true
        errorMessage = nil

        viewModel.submitRole(role) { success in
            DispatchQueue.main.async {
                isSubmitting = false
                if success {
                    close()
                } else {
                    errorMessage = viewModel.errorMessage
                }
            }
        }
    }

    private func close() {
        isActive = false
    }
}

struct RoleOptionView: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppStyle.Colors.accent)
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppStyle.Fonts.vollkornBold(20))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(AppStyle.Fonts.vollkornMedium(13))
                    .foregroundColor(AppStyle.Colors.accent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    RoleSelectionDialog(isActive: .constant(true))
}
