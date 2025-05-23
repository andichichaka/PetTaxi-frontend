import SwiftUI

struct AuthTextField: View {
    let title: String
    @Binding var text: String
    var focusState: FocusState<FocusField?>.Binding
    let assignedFocus: FocusField
    var isSecure: Bool = false
    var errorMessage: String
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
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
                    .cornerRadius(20)
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
                    .cornerRadius(20)
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
            focusState.wrappedValue = nil
        }
    }
}
