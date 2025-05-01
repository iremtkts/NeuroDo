import UIKit

final class AIAssistantViewController: UIViewController {
    
    private let moodTextView: UITextView = {
        let tv = UITextView()
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.font = .systemFont(ofSize: 16)
        tv.text = "Bugün nasılsın?"
        return tv
    }()
    
    private let analyzeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Analiz Et 🧠", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "Öneriler burada görünecek"
        label.numberOfLines = 0
        return label
    }()
    
    private let viewModel = AIAssistantViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        title = "AI Asistan"
        view.backgroundColor = .systemBackground
        moodTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true 
        let stack = UIStackView(arrangedSubviews: [
            moodTextView,
            analyzeButton,
            resultLabel
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
        
        analyzeButton.addTarget(self, action: #selector(analyzeTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onResultUpdated = { [weak self] in
            guard let result = self?.viewModel.moodResult else { return }
            let formatted = result.suggestions.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n")
            self?.resultLabel.text = "🧠 Ruh hali: \(result.mood)\n\n✅ Öneriler:\n\(formatted)"
        }
        
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "Uyarı", message: message)
        }
    }
    
    @objc private func analyzeTapped() {
        viewModel.moodInput = moodTextView.text
        viewModel.analyze()
    }
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(.init(title: "Tamam", style: .default))
        present(ac, animated: true)
    }
}
