//
//  RoleManager.swift
//  PetTaxi
//
//  Created by Andrey on 13.01.25.
//

import Combine
import SwiftUI

class RoleManager: ObservableObject {
    @Published var userRole: String = UserDefaults.standard.string(forKey: "userRole") ?? "user"
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.userRole = UserDefaults.standard.string(forKey: "userRole") ?? "user"
            }
            .store(in: &cancellables)
    }
}
