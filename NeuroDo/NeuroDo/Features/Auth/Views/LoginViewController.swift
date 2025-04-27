import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Şifre"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Giriş Yap", for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - ViewModel
    private let viewModel = LoginViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        title = "NeuroDo - Giriş"
        view.backgroundColor = .systemBackground
        
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, loadingIndicator])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {

        viewModel.onLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
                self?.loginButton.isEnabled = false
            } else {
                self?.loadingIndicator.stopAnimating()
                self?.loginButton.isEnabled = true
            }
        }
        
      
        viewModel.onError = { [weak self] errorMessage in
            self?.showAlert(title: "Hata", message: errorMessage)
        }
        
   
        viewModel.onLoginSuccess = { [weak self] in
            self?.showAlert(title: "Başarılı", message: "Giriş başarılı!") {
                // TODO: Ana ekrana yönlendirme yapılacak
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        viewModel.email = emailTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        viewModel.login()
    }
    
    // MARK: - Helper
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { _ in
            completion?()
        }))
        present(alertVC, animated: true, completion: nil)
    }
}
