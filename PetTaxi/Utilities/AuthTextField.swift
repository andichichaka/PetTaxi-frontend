//
//  AuthTextField.swift
//  PetTaxi
//
//  Created by Andrey on 23.12.24.
//

import SwiftUI

struct AuthTextField: View {
    let title: String
    @Binding var text: String
    var focusState: FocusState<FocusField?>.Binding
    let assignedFocus: FocusField
    var isSecure: Bool = false
    var errorMessage: String
    var onSubmit: (() -> Void)? = nil // Called when Enter is pressed

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            if isSecure {
                SecureField("", text: $text)
                    .focused(focusState, equals: assignedFocus)
                    .submitLabel(.next)
                    .onSubmit {
                        focusToNextField()
                        onSubmit?()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            } else {
                TextField("", text: $text)
                    .focused(focusState, equals: assignedFocus)
                    .submitLabel(.next)
                    .onSubmit {
                        focusToNextField()
                        onSubmit?()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            }
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    private func focusToNextField() {
        switch assignedFocus {
        case .username:
            focusState.wrappedValue = .email
        case .email:
            focusState.wrappedValue = .password
        case .password:
            focusState.wrappedValue = .repeatPassword
        case .repeatPassword:
            focusState.wrappedValue = nil // Dismiss keyboard
        }
    }
}
