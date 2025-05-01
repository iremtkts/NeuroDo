import UIKit

final class TaskCreateViewController: UIViewController {
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Görev Başlığı"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Açıklama (isteğe bağlı)"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Görev Ekle", for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private let viewModel = TaskCreateViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        title = "Görev Ekle"
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView(arrangedSubviews: [
            titleTextField,
            descriptionTextField,
            addButton
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
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onSuccess = { [weak self] in
            self?.showAlert(title: "Başarılı", message: "Görev eklendi!") {
                self?.tabBarController?.selectedIndex = 0 // Görevler sekmesine dön
            }
        }
        
        viewModel.onError = { [weak self] error in
            self?.showAlert(title: "Hata", message: error)
        }
    }
    
    @objc private func addButtonTapped() {
        viewModel.title = titleTextField.text ?? ""
        viewModel.description = descriptionTextField.text ?? ""
        viewModel.addTask()
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Tamam", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }
}
