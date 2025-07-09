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
    
    private let goToSignUpButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(
            string: "Hesabınız yok mu? ",
            attributes: [
                .foregroundColor: UIColor.label,
                .font: UIFont.systemFont(ofSize: 14)
            ]
        )
        attributedTitle.append(NSAttributedString(
            string: "Kayıt Ol",
            attributes: [
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.boldSystemFont(ofSize: 14)
            ]
        ))
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
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
        title = "NeuroDo"
        view.backgroundColor = .systemBackground

        // 1. Görsel (login.png)
        let imageView = UIImageView(image: UIImage(named: "9"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        // 2. Slogan Label
        let sloganLabel = UILabel()
        sloganLabel.text = "Üretken olmaya giriş yap"
        sloganLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        sloganLabel.textAlignment = .center
        sloganLabel.textColor = .secondaryLabel

        // 3. Stack View (Form alanları)
        let formStack = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton,
            loadingIndicator,
            goToSignUpButton
        ])
        formStack.axis = .vertical
        formStack.spacing = 16

        // 4. Ana Stack
        let mainStack = UIStackView(arrangedSubviews: [
            imageView,
            sloganLabel,
            formStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 24
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // 5. Buton aksiyonları
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        goToSignUpButton.addTarget(self, action: #selector(goToSignUpTapped), for: .touchUpInside)
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
                let tabBar = MainTabBarController()
                self?.navigationController?.setViewControllers([tabBar], animated: true)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        viewModel.email = emailTextField.text ?? ""
        viewModel.password = passwordTextField.text ?? ""
        viewModel.login()
    }
    
    @objc private func goToSignUpTapped() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
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
