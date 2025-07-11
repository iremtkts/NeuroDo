import UIKit

final class AIChatViewController: UIViewController {

    private let mascotImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "10"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.text = "Merhaba, bugününü planlayalım 🧠"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageInputView: UITextView = {
        let tv = UITextView()
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.cornerRadius = 8
        tv.font = .systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Gönder", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let progressIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Gününü planlıyorum..."
        label.textAlignment = .center
        label.font = .italicSystemFont(ofSize: 14)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let viewModel = AIAssistantViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageInputView.text = ""
    }

    private func setupUI() {
        title = "AI Asistan"
        view.backgroundColor = .systemBackground

        view.addSubview(mascotImageView)
        view.addSubview(greetingLabel)
        view.addSubview(messageInputView)
        view.addSubview(sendButton)
        view.addSubview(progressIndicator)
        view.addSubview(progressLabel)

        NSLayoutConstraint.activate([
            mascotImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            mascotImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mascotImageView.heightAnchor.constraint(equalToConstant: 80),

            greetingLabel.topAnchor.constraint(equalTo: mascotImageView.bottomAnchor, constant: 16),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            greetingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            messageInputView.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 16),
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            messageInputView.heightAnchor.constraint(equalToConstant: 100),

            sendButton.topAnchor.constraint(equalTo: messageInputView.bottomAnchor, constant: 16),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            sendButton.heightAnchor.constraint(equalToConstant: 44),

            progressIndicator.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 16),
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            progressLabel.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            progressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }

    private func setupBindings() {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.progressLabel.isHidden = !isLoading
                isLoading ? self?.progressIndicator.startAnimating() : self?.progressIndicator.stopAnimating()
                self?.sendButton.isEnabled = !isLoading
            }
        }

        viewModel.onSuccess = { [weak self] in
            DispatchQueue.main.async {
                let taskVC = TaskListViewController()
                self?.navigationController?.pushViewController(taskVC, animated: true)
            }
        }


        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(title: "Hata", message: message)
            }
        }
    }

    @objc private func sendTapped() {
        sendButton.isEnabled = false 
        let message = messageInputView.text ?? ""
        viewModel.sendMessage(message: message)
    }


    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(.init(title: "Tamam", style: .default))
        present(ac, animated: true)
    }
}
