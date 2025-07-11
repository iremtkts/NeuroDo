import Foundation


final class SignUpViewModel: BaseViewModel {
    

    var email: String = ""
    var password: String = ""
    
    var onSignUpSuccess: (() -> Void)?
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty else {
            onError?("Email ve şifre boş bırakılamaz.")
            return
        }

        isLoading = true

        let request = SignUpRequest(email: email, password: password)
        
        guard let requestBody = try? JSONEncoder().encode(request) else {
            isLoading = false
            onError?("Veri kodlama hatası oluştu.")
            return
        }

        // 💡 JSON verisini yazdır (debug için)
        if let jsonString = String(data: requestBody, encoding: .utf8) {
            print("🟢 Gönderilen JSON:", jsonString)
        }

        let endpoint = Endpoint(
            path: "/api/v1/auth/signup",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: requestBody
        )

        APIService.shared.request(endpoint: endpoint, responseModel: SignUpResponse.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(_):
                self.onSignUpSuccess?()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    func verifyEmail(code: String, completion: @escaping (Bool) -> Void) {
        guard let emailEncoded = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let codeEncoded = code.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(false)
            return
        }

        let urlString = "https://neurodo-production.up.railway.app/api/v1/auth/verify?email=\(emailEncoded)&code=\(codeEncoded)"

        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }

}
