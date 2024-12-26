import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusField: FocusField?
    @State private var showHomePage = false
    @StateObject private var signUpManager = SignUpManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Sign Up Fields
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
                        title: "Email",
                        text: $viewModel.userEmail,
                        focusState: $focusField,
                        assignedFocus: .email,
                        errorMessage: viewModel.userEmailError,
                        onSubmit: {
                            viewModel.validatedFields.insert(.email)
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
                    AuthTextField(
                        title: "Repeat Password",
                        text: $viewModel.userRepeatedPassword,
                        focusState: $focusField,
                        assignedFocus: .repeatPassword,
                        isSecure: true,
                        errorMessage: viewModel.userRepeatedPasswordError,
                        onSubmit: {
                            viewModel.validatedFields.insert(.repeatPassword)
                        }
                    )
                }
                .padding()

                // Sign Up Button
                Button(action: {
                    let newProfile = SignUp(
                        username: viewModel.userName,
                        email: viewModel.userEmail,
                        password: viewModel.userPassword
                    )
                    let signUpManager = SignUpManager()
                    signUpManager.saveProfile(profile: newProfile, apiURL: "http://localhost:3000/auth/signup") { success, token in
                        
                        if success, let token = token {
                            TokenManager.shared.saveToken(token)
                            DispatchQueue.main.async {
                                showHomePage = true
                            }
                        } else {
                            DispatchQueue.main.async {
                                print("SignUp failed. Please try again.")
                            }
                        }
                    }
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.yellow : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                .padding(.horizontal)
                .disabled(!viewModel.isFormValid)

                // Error Message (Uncomment if error handling is implemented in the future)
//                // Error Message
                if let errorMessage = signUpManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Spacer()

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $showHomePage) {
                HomePageView()
            }
        }
    }
}
