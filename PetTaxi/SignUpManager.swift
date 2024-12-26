import Foundation
import Combine

class SignUpManager: ObservableObject {
    @Published var errorMessage: String?

    func saveProfile(profile: SignUp, apiURL: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: apiURL) else {
            print("Invalid URL")
            completion(false, nil)
            return
        }

        guard let jsonData = try? JSONEncoder().encode(profile) else {
            print("Failed to encode JSON")
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        print("Sending Request to \(apiURL): \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")")

        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
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

            print("Response Data: \(String(data: data, encoding: .utf8) ?? "No readable data")")

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SignUpResponse.self, from: data)

                if response.success, let token = response.access_token {
                    completion(true, token)
                } else {
                    completion(false, nil)
                    print("Hi")
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(false, nil)
            }
        }
        task.resume()
    }
}
