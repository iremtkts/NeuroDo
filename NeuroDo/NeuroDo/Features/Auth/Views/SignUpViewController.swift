import UIKit

final class SignUpViewController: UIViewController {

    // MARK: - UI Elements

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

        let imageView = UIImageView(image: UIImage(named: "4"))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        let sloganLabel = UILabel()
        sloganLabel.text = "Yeni bir başlangıç için kaydol"
        sloganLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        sloganLabel.textAlignment = .center
        sloganLabel.textColor = .secondaryLabel

        let formStack = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            signUpButton,
            loadingIndicator
        ])
        formStack.axis = .vertical
        formStack.spacing = 16

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
        present(alertVC, animated: true)
    }
}
