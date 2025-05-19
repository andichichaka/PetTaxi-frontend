import SwiftUI

struct VerificationCodeDialog: View {
    @Binding var isActive: Bool
    @Binding var verificationCode: String

    let verifyAction: () -> Void

    @State private var isVerifying = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { close() }

            VStack(spacing: 20) {
                titleSection
                instructionsText
                codeField
                errorText
                verifyButton
                closeButton
            }
            .padding()
            .background(AppStyle.Colors.light)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(30)
        }
    }

    // MARK: - Subviews

    private var titleSection: some View {
        Text("Verify Your Email")
            .font(AppStyle.Fonts.vollkornBold(24))
            .foregroundColor(AppStyle.Colors.base)
            .padding(.top, 20)
    }

    private var instructionsText: some View {
        Text("Please enter the verification code we sent to your email to activate your account.")
            .font(AppStyle.Fonts.vollkornRegular(16))
            .foregroundColor(AppStyle.Colors.base.opacity(0.8))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    private var codeField: some View {
        TextField("Enter Verification Code", text: $verificationCode)
            .keyboardType(.numberPad)
            .font(AppStyle.Fonts.vollkornRegular(16))
            .padding()
            .background(.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppStyle.Colors.secondary.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
    }

    private var errorText: some View {
        Group {
            if let error = errorMessage {
                Text(error)
                    .font(AppStyle.Fonts.vollkornMedium(14))
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
        }
    }

    private var verifyButton: some View {
        Button {
            guard !verificationCode.isEmpty else {
                errorMessage = "Please enter a verification code"
                return
            }
            isVerifying = true
            verifyAction()
        } label: {
            Text(isVerifying ? "Verifying..." : "Verify")
                .font(AppStyle.Fonts.vollkornBold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(verificationCode.isEmpty ? .gray : AppStyle.Colors.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
        .disabled(verificationCode.isEmpty || isVerifying)
        .padding(.horizontal)
    }

    private var closeButton: some View {
        Button {
            close()
        } label: {
            Text("Close")
                .font(AppStyle.Fonts.vollkornBold(16))
                .foregroundColor(AppStyle.Colors.base)
                .padding(.top, 10)
        }
    }

    // MARK: - Helpers

    private func close() {
        isActive = false
    }
}
