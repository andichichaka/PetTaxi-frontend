import Foundation
import Combine

class AuthViewModel: ObservableObject {
    // Input fields
    @Published var userName = ""
    @Published var userEmail = ""
    @Published var userPassword = ""
    @Published var userRepeatedPassword = ""
    
    // Validation states
    @Published var userNameError: String = ""
    @Published var userEmailError: String = ""
    @Published var userPasswordError: String = ""
    @Published var userRepeatedPasswordError: String = ""

    // Tracks fields that have been validated (after Enter)
    @Published var validatedFields: Set<FocusField> = []

    // Form validation state
    @Published var isFormValid = false

    // Tracks required fields for validation
    private let requiredFields: Set<FocusField> = [.username, .email, .password, .repeatPassword]

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupValidation()
    }

    private func setupValidation() {
        // Username validation
        $userName
            .combineLatest($validatedFields)
            .map { name, validatedFields in
                if validatedFields.contains(.username) {
                    return name.count >= 5 ? "" : "Username must be at least 5 characters"
                }
                return ""
            }
            .assign(to: &$userNameError)

        // Email validation
        $userEmail
            .combineLatest($validatedFields)
            .map { email, validatedFields in
                if validatedFields.contains(.email) {
                    return self.isValidEmail(email) ? "" : "Invalid email format"
                }
                return ""
            }
            .assign(to: &$userEmailError)

        // Password validation
        $userPassword
            .combineLatest($validatedFields)
            .map { password, validatedFields in
                if validatedFields.contains(.password) {
                    return self.validatePassword(password)
                }
                return ""
            }
            .assign(to: &$userPasswordError)

        // Repeat password validation
        Publishers.CombineLatest3($userPassword, $userRepeatedPassword, $validatedFields)
            .map { password, repeated, validatedFields in
                if validatedFields.contains(.repeatPassword) {
                    return password == repeated ? "" : "Passwords do not match"
                }
                return ""
            }
            .assign(to: &$userRepeatedPasswordError)

        // Form validity (only valid if all fields are validated and valid)
        Publishers.CombineLatest4($userNameError, $userEmailError, $userPasswordError, $userRepeatedPasswordError)
            .combineLatest($validatedFields)
            .map { errors, validatedFields in
                let (nameError, emailError, passwordError, repeatedError) = errors
                let allFieldsValidated = self.requiredFields.isSubset(of: validatedFields)
                return allFieldsValidated &&
                    nameError.isEmpty &&
                    emailError.isEmpty &&
                    passwordError.isEmpty &&
                    repeatedError.isEmpty
            }
            .assign(to: &$isFormValid)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func validatePassword(_ password: String) -> String {
        // Prioritized password validation
        if password.count < 8 {
            return "Password must be at least 8 characters"
        }
        if !password.contains(where: { $0.isUppercase }) {
            return "Password must contain at least one uppercase letter"
        }
        if !password.contains(where: { $0.isNumber }) {
            return "Password must contain at least one number"
        }
        return ""
    }
}
