//
//  LogInViewModel.swift
//  PetTaxi
//
//  Created by Andrey on 23.12.24.
//

import Foundation
import Combine

final class LogInViewModel: ObservableObject {
    @Published var userName = ""
    @Published var userPassword = ""
    @Published var validatedFields: Set<FocusField> = []
    
    @Published var userNameError: String = ""
    @Published var userPasswordError: String = ""
    
    @Published var isFormFilled: Bool = false

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
}
