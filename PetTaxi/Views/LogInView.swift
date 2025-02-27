import SwiftUI

struct LogInView: View {
    @StateObject private var viewModel = LogInViewModel()
    @FocusState private var focusField: FocusField?
    @State private var showHomePage = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
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

                Button(action: {
                    let newProfile = LogIn(
                        username: viewModel.userName,
                        password: viewModel.userPassword
                    )
                    viewModel.logIn(profile: newProfile) { success in
                        
                        if success {
                            DispatchQueue.main.async {
                                showHomePage = true
                            }
                        } else {
                            DispatchQueue.main.async {
                                print("Login failed. Please try again.")
                            }
                        }
                    }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormFilled ? Color.color3 : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(radius: 3)
                }
                .padding(.horizontal)
                .disabled(!viewModel.isFormFilled)
                
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
            .navigationDestination(isPresented: $showHomePage) {
                NavigationBarView()
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}
