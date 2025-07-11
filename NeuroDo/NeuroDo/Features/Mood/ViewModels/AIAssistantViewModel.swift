import Foundation

final class AIAssistantViewModel {
    var onLoadingStateChange: ((Bool) -> Void)?
    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    private var isLoading: Bool = false {
        didSet {
            onLoadingStateChange?(isLoading)
        }
    }

    private let chatService: AIChatServiceProtocol

    init(chatService: AIChatServiceProtocol = AIChatService.shared) {
        self.chatService = chatService
    }

    func sendMessage(message: String) {
        guard !message.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?("Lütfen bir mesaj girin.")
            return
        }

        isLoading = true
        chatService.sendChatMessage(message) { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success {
                    self?.onSuccess?()
                } else {
                    self?.onError?("Görevler oluşturulamadı. Lütfen tekrar deneyin.")
                }
            }
        }
    }
}
