import UIKit

final class AIAssistantViewController: UIViewController {
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Bugün nasılsın?"
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private let moodTextView: UITextView = {
        let tv = UITextView()
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.layer.borderColor = UIColor.systemGray.cgColor
        tv.font = .systemFont(ofSize: 16)
        return tv
    }()
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "7")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.heightAnchor.constraint(equalToConstant: 150).isActive = true
        return iv
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

        // Placeholder'ı textView'e ekle
        moodTextView.addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        moodTextView.translatesAutoresizingMaskIntoConstraints = false
        moodTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: moodTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: moodTextView.leadingAnchor, constant: 5)
        ])

        // StackView içinde sıralama: Görsel > TextView > Buton > Sonuç Label
        let stack = UIStackView(arrangedSubviews: [
            imageView,
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

        // Yazmaya başlayınca placeholder gizlensin
        NotificationCenter.default.addObserver(
            forName: UITextView.textDidChangeNotification,
            object: moodTextView,
            queue: .main
        ) { [weak self] _ in
            self?.placeholderLabel.isHidden = !(self?.moodTextView.text.isEmpty ?? true)
        }

        analyzeButton.addTarget(self, action: #selector(analyzeTapped), for: .touchUpInside)
    }

    
    private func setupBindings() {
        viewModel.onResultUpdated = { [weak self] in
            guard let result = self?.viewModel.moodResult else { return }
            let formatted = result.suggestions.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n")
            self?.resultLabel.text = "✅ Öneriler:\n\(formatted)"

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
