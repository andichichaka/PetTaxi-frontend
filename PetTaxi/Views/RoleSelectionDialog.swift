import SwiftUI

struct RoleSelectionDialog: View {
    @Binding var isActive: Bool
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.5)
                .onTapGesture {
                }

            VStack(spacing: 20) {
                Text("Choose Your Role")
                    .font(.custom("Vollkorn-Bold", size: 25))
                    .bold()
                    .padding(.top)
                    .padding(.bottom, -5)

                Text("Select how you'll be using our platform")
                    .font(.custom("Vollkorn-Medium", size: 17))
                    .multilineTextAlignment(.center)
                    .padding(.bottom)

                VStack(spacing: 16) {
                    Button(action: {
                        submitRole("admin")
                        UserDefaults.standard.set("admin", forKey: "userRole")
                    }) {
                        RoleOptionView(
                            title: "Caretaker",
                            subtitle: "I want to provide pet care services",
                            icon: "heart.fill"
                        )
                    }

                    Button(action: {
                        submitRole("user")
                        UserDefaults.standard.set("user", forKey: "userRole")
                    }) {
                        RoleOptionView(
                            title: "Regular User",
                            subtitle: "I am looking for pet care services",
                            icon: "person.fill"
                        )
                    }
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top)
                }

                if isSubmitting {
                    ProgressView("Submitting...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        .padding()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(30)
        }
        .ignoresSafeArea()
    }

    private func submitRole(_ role: String) {
        isSubmitting = true
        errorMessage = nil

        viewModel.submitRole(role) { success in
            DispatchQueue.main.async {
                isSubmitting = false
                if success {
                    isSubmitting = false
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
                .foregroundColor(Color.color3)
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Vollkorn-Bold", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.custom("Vollkorn-Medium", size: 13))
                    .foregroundColor(Color.color3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview{
    RoleSelectionDialog(isActive: .constant(true))
}
