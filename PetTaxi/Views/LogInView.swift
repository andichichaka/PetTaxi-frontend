import SwiftUI

struct LogInView: View {
    @StateObject private var viewModel = LogInViewModel()
    @FocusState private var focusField: FocusField?
    @State private var showHomePage = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                inputFieldsSection

                loginButton

                if let errorMessage = viewModel.errorMessage {
                    errorText(message: errorMessage)
                }

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $showHomePage) {
                NavigationBarView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    // MARK: - Input Fields
    private var inputFieldsSection: some View {
        VStack(spacing: 16) {
            AuthTextField(
                title: "Username",
                text: $viewModel.userName,
                focusState: $focusField,
                assignedFocus: .username,
                errorMessage: viewModel.userNameError,
                onSubmit: {
                    viewModel.validatedFields.insert(.username)
                }
            )

            AuthTextField(
                title: "Password",
                text: $viewModel.userPassword,
                focusState: $focusField,
                assignedFocus: .password,
                isSecure: true,
                errorMessage: viewModel.userPasswordError,
                onSubmit: {
                    viewModel.validatedFields.insert(.password)
                }
            )
        }
        .padding()
    }

    // MARK: - Login Button
    private var loginButton: some View {
        Button(action: logInAction) {
            Text("Login")
                .font(AppStyle.Fonts.vollkornBold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isFormFilled ? AppStyle.Colors.accent : .gray)
                .foregroundColor(.white)
                .cornerRadius(25)
                .shadow(radius: 3)
        }
        .padding(.horizontal)
        .disabled(!viewModel.isFormFilled)
    }

    // MARK: - Error Message
    private func errorText(message: String) -> some View {
        Text(message)
            .foregroundColor(.red)
            .font(AppStyle.Fonts.vollkornRegular(14))
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }

    // MARK: - Login Logic
    private func logInAction() {
        let credentials = LogIn(
            username: viewModel.userName,
            password: viewModel.userPassword
        )

        viewModel.logIn(profile: credentials) { success in
            DispatchQueue.main.async {
                showHomePage = success
                if !success {
                    print("Login failed. Please try again.")
                }
            }
        }
    }
}
