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
        
        let loginRequest = LoginRequest(email: email, password: password)
        
        guard let requestBody = try? JSONEncoder().encode(loginRequest) else {
            isLoading = false
            onError?("Veri kodlama hatası oluştu.")
            return
        }
        
        let endpoint = Endpoint(
            path: "/auth/login",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: requestBody
        )
        
        APIService.shared.request(endpoint: endpoint, responseModel: LoginResponse.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                // Token kaydı
                TokenManager.shared.saveToken(token: response.accessToken, tokenType: response.tokenType)
                self.onLoginSuccess?()
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
}
