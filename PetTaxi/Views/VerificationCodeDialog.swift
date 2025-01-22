//
//  VerificationCodeDialog.swift
//  PetTaxi
//
//  Created by Andrey on 20.01.25.
//

import SwiftUI

struct VerificationCodeDialog: View {
    @Binding var isActive: Bool
    @Binding var verificationCode: String

    let verifyAction: () -> Void
    let resendAction: () -> Void

    @State private var isVerifying = false
    @State private var isResending = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.5)
                .onTapGesture {
                    close()
                }

            VStack(spacing: 20) {
                Text("Verify Your Email")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                Text("Please enter the verification code we sent to your email to activate your account.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                TextField("Enter Verification Code", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top)
                }

                HStack(spacing: 15) {
                    Button(action: {
                        resendAction()
                        isResending = true
                    }) {
                        Text(isResending ? "Resending..." : "Resend Code")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .disabled(isResending)

                    Button(action: {
                        guard !verificationCode.isEmpty else {
                            errorMessage = "Please enter a verification code"
                            return
                        }
                        isVerifying = true
                        verifyAction()
                    }) {
                        Text(isVerifying ? "Verifying..." : "Verify")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(verificationCode.isEmpty ? Color.gray : Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(verificationCode.isEmpty || isVerifying)
                }

                Button(action: {
                    close()
                }) {
                    Text("Cancel")
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 20)
            .padding(30)
        }
        .ignoresSafeArea()
    }

    private func close() {
        isActive = false
    }
}
