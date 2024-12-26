import Foundation
import Combine

class LogInManager: ObservableObject {
    @Published var errorMessage: String?

    func checkInfo(profile: LogIn, apiURL: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: apiURL) else {
            print("Invalid URL")
            completion(false, nil)
            return
        }

        guard let jsonData = try? JSONEncoder().encode(profile) else {
            print("Failed to encode profile")
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Request failed: \(error.localizedDescription)"
                }
                completion(false, nil)
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received from server"
                }
                completion(false, nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(LoginResponse.self, from: data)

                print("Parsed Response: \(response)")
                print("Success: \(response.success), Access Token: \(response.access_token ?? "No Token")")

                if response.success, let token = response.access_token {
                    completion(true, token)
                } else {
                    self.errorMessage = response.message
                    print("Error Message: \(self.errorMessage ?? "No Error")")
                    completion(false, nil)
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(false, nil)
            }

        }
        task.resume()
    }
}
