import UIKit

final class SignUpViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "İsim"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        return textField
    }()
    
    private let lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Soyisim"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Şifre"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kayıt Ol", for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemGreen
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
    private let viewModel = SignUpViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        title = "NeuroDo - Kayıt Ol"
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView(arrangedSubviews: [
            firstNameTextField,
            lastNameTextField,
            emailTextField,
            passwordTextField,
            signUpButton,
            loadingIndicator
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
                self?.signUpButton.isEnabled = false
            } else {
                self?.loadingIndicator.stopAnimating()
                self?.signUpButton.isEnabled = true
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            self?.showAlert(title: "Hata", message: errorMessage)
        }
        
        viewModel.onSignUpSuccess = { [weak self] in
            self?.showAlert(title: "Başarılı", message: "Kayıt başarılı!") {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func signUpButtonTapped() {
        viewModel.firstName = firstNameTextField.text ?? ""
        viewModel.lastName = lastNameTextField.text ?? ""
        viewModel.email = emailTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        viewModel.signUp()
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
