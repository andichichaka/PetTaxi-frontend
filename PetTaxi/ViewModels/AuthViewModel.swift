import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var userName = ""
    @Published var userEmail = ""
    @Published var userPassword = ""
    @Published var userRepeatedPassword = ""

    @Published var userNameError: String = ""
    @Published var userEmailError: String = ""
    @Published var userPasswordError: String = ""
    @Published var userRepeatedPasswordError: String = ""

    @Published var validatedFields: Set<FocusField> = []

    @Published var isFormValid = false

    private let requiredFields: Set<FocusField> = [.username, .email, .password, .repeatPassword]

    private var cancellables = Set<AnyCancellable>()

    @Published var errorMessage: String?
    private let communicationManager = CommunicationManager.shared

    init() {
        setupValidation()
    }

    private func setupValidation() {
            $userName
                .combineLatest($validatedFields)
                .map { name, validatedFields in
                    if validatedFields.contains(.username) {
                        return name.count >= 5 ? "" : "Username must be at least 5 characters"
                    }
                    return ""
                }
                .assign(to: &$userNameError)

            $userEmail
                .combineLatest($validatedFields)
                .map { email, validatedFields in
                    if validatedFields.contains(.email) {
                        return self.isValidEmail(email) ? "" : "Invalid email format"
                    }
                    return ""
                }
                .assign(to: &$userEmailError)

            $userPassword
                .combineLatest($validatedFields)
                .map { password, validatedFields in
                    if validatedFields.contains(.password) {
                        return self.validatePassword(password)
                    }
                    return ""
                }
                .assign(to: &$userPasswordError)

            Publishers.CombineLatest3($userPassword, $userRepeatedPassword, $validatedFields)
                .map { password, repeated, validatedFields in
                    if validatedFields.contains(.repeatPassword) {
                        return password == repeated ? "" : "Passwords do not match"
                    }
                    return ""
                }
                .assign(to: &$userRepeatedPasswordError)

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

    func signUp(profile: SignUp, completion: @escaping (Bool) -> Void) {
        communicationManager.execute(
            endpoint: .signUp,
            body: profile,
            responseType: SignUpResponse.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        completion(true)
                    } else {
                        self.errorMessage = response.message ?? "Sign up failed."
                        completion(false)
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    func verifyEmail(email: String, code: String, completion: @escaping (Bool) -> Void) {
        communicationManager.execute(
            endpoint: .verifyEmail,
            body: ["email": email, "code": code],
            responseType: VerifyEmailResponse.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let access_token = response.access_token, let refresh_token = response.refresh_token {
                        TokenManager.shared.saveTokens(accessToken: access_token, refreshToken: refresh_token)
                        completion(true)
                    } else {
                        self.errorMessage = response.message ?? "Verification failed."
                        completion(false)
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}
