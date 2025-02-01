import SwiftUI

struct VerificationCodeDialog: View {
    @Binding var isActive: Bool
    @Binding var verificationCode: String

    let verifyAction: () -> Void

    @State private var isVerifying = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    close()
                }

            // Dialog Content
            VStack(spacing: 20) {
                // Title
                Text("Verify Your Email")
                    .font(.custom("Vollkorn-Bold", size: 24)) // Custom Font
                    .foregroundColor(.color) // Dark Green
                    .padding(.top, 20)

                // Description
                Text("Please enter the verification code we sent to your email to activate your account.")
                    .font(.custom("Vollkorn-Regular", size: 16)) // Custom Font
                    .foregroundColor(.color.opacity(0.8)) // Dark Green with opacity
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Verification Code TextField
                TextField("Enter Verification Code", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .font(.custom("Vollkorn-Regular", size: 16)) // Custom Font
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.color2.opacity(0.5), lineWidth: 1) // Light Green border
                    )
                    .padding(.horizontal)

                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.custom("Vollkorn-Medium", size: 14)) // Custom Font
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }

                // Verify Button
                Button(action: {
                    guard !verificationCode.isEmpty else {
                        errorMessage = "Please enter a verification code"
                        return
                    }
                    isVerifying = true
                    verifyAction()
                }) {
                    Text(isVerifying ? "Verifying..." : "Verify")
                        .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(verificationCode.isEmpty ? Color.gray : Color.color3) // Mint Green
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                }
                .disabled(verificationCode.isEmpty || isVerifying)
                .padding(.horizontal)

                // Close Button
                Button(action: {
                    close()
                }) {
                    Text("Close")
                        .font(.custom("Vollkorn-Bold", size: 16)) // Custom Font
                        .foregroundColor(.color) // Dark Green
                        .padding(.top, 10)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(30)
        }
    }

    // Close the dialog
    private func close() {
        isActive = false
    }
}
