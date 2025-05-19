import Foundation
import Combine

final class LogInViewModel: ObservableObject {
    @Published var userName = ""
    @Published var userPassword = ""
    @Published var validatedFields: Set<FocusField> = []
    
    @Published var userNameError: String = ""
    @Published var userPasswordError: String = ""
    
    @Published var isFormFilled: Bool = false
    
    @Published var errorMessage: String?
    private let communicationManager = CommunicationManager.shared

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupValidation()
    }

    private func setupValidation() {
        $userName
            .combineLatest($validatedFields)
            .map { name, validatedFields in
                if validatedFields.contains(.username) {
                    return name.isEmpty ? "Empty field" : ""
                }
                return ""
            }
            .assign(to: &$userNameError)
        
        $userPassword
            .combineLatest($validatedFields)
            .map { password, validatedFields in
                if validatedFields.contains(.password) {
                    return password.isEmpty ? "Empty field" : ""
                }
                return ""
            }
            .assign(to: &$userPasswordError)
        
        Publishers.CombineLatest($userName, $userPassword)
                    .map { !$0.isEmpty && !$1.isEmpty }
                    .assign(to: &$isFormFilled)
    }
    
    func logIn(profile: LogIn, completion: @escaping (Bool) -> Void) {
        communicationManager.execute(
            endpoint: .logIn,
            body: profile,
            responseType: LoginResponse.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success, let access_token = response.access_token, let refresh_token = response.refresh_token, let role = response.user?.role {
                        UserDefaults.standard.set(role, forKey: "userRole")
                        TokenManager.shared.saveTokens(accessToken: access_token, refreshToken: refresh_token)
                        //print("\(refresh_token)")
                        completion(true)
                    } else {
                        self.errorMessage = response.message ?? "Login failed."
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
