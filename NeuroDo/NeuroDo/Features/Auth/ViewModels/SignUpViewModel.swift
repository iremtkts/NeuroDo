import Foundation

final class SignUpViewModel: BaseViewModel {
    
    
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    
   
    var onSignUpSuccess: (() -> Void)?
    
    func signUp() {
     
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            onError?("Tüm alanlar doldurulmalıdır.")
            return
        }
        
        isLoading = true
        
        let signUpRequest = SignUpRequest(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        )
        
        guard let requestBody = try? JSONEncoder().encode(signUpRequest) else {
            isLoading = false
            onError?("Veri kodlama hatası oluştu.")
            return
        }
        
        let endpoint = Endpoint(
            path: "/auth/register",
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
}
