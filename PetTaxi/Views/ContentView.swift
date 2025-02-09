import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false

    var body: some View {
        NavigationStack {
            if isAuthenticated {
                NavigationBarView()
            } else {
                AuthView()
            }
        }
        .onAppear {
            TokenManager.shared.verifyAccessToken { success in
                DispatchQueue.main.async {
                    self.isAuthenticated = success
                }
            }
        }
    }
}

#Preview{
    ContentView()
}
