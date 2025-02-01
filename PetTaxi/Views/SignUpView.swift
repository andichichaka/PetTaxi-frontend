import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusField: FocusField?
    @State private var showHomePage = false
    @State private var showVerificationDialog = false
    @State private var verificationCode = ""

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
                    viewModel.signUp(profile: newProfile) { success in
                        if success {
                            DispatchQueue.main.async {
                                showVerificationDialog = true
                            }
                        } else {
                            print("SignUp failed. Please try again.")
                        }
                    }
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.color3 : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(radius: 3)
                }
                .disabled(!viewModel.isFormValid)
                .padding(.horizontal)

                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Spacer()
            }
            .padding()
            .fullScreenCover(isPresented: $showVerificationDialog) {
                VerificationCodeDialog(
                    isActive: $showVerificationDialog,
                    verificationCode: $verificationCode,
                    verifyAction: {
                        viewModel.verifyEmail(email: viewModel.userEmail, code: verificationCode) { success in
                            if success {
                                DispatchQueue.main.async {
                                    showVerificationDialog = false
                                    //UserDefaults.standard.set("user", forKey: "userRole")
                                    showHomePage = true
                                    UserDefaults.standard.set(true, forKey: "showProfileDialog")
                                }
                            } else {
                                print("Verification failed.")
                            }
                        }
                    }
                )
        }
            .navigationDestination(isPresented: $showHomePage) {
                NavigationBarView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}
