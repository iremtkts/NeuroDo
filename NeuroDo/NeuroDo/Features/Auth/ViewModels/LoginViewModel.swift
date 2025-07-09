import Foundation

final class LoginViewModel: BaseViewModel {
    
    
    var email: String = ""
    var password: String = ""
    
    
    var onLoginSuccess: (() -> Void)?
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            onError?("Email ve şifre boş bırakılamaz.")
            return
        }

        isLoading = true

        let parameters = [
            "username": email,
            "password": password
        ]

        let formBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        

        let endpoint = Endpoint(
            path: "/api/v1/auth/login",
            method: .POST,
            headers: [
                "Content-Type": "application/x-www-form-urlencoded"
            ],
            body: formBody
        )

        APIService.shared.request(endpoint: endpoint, responseModel: LoginResponse.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                TokenManager.shared.saveToken(token: response.accessToken, tokenType: response.tokenType)
                self.onLoginSuccess?()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }

}
