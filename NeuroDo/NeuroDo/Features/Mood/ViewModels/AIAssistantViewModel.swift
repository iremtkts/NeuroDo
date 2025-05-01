import Foundation

final class AIAssistantViewModel {
    
    var moodInput: String = ""
    
    var moodResult: MoodAnalysisResponse? {
        didSet {
            onResultUpdated?()
        }
    }
    
    var onResultUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private let analyzer: MoodAnalyzerProtocol
    
    init(analyzer: MoodAnalyzerProtocol = MockMoodAnalyzer()) {
        self.analyzer = analyzer
    }
    
    func analyze() {
        guard !moodInput.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?("Lütfen ruh halinizi girin.")
            return
        }
        
        analyzer.analyzeMood(from: moodInput) { [weak self] result in
            self?.moodResult = result
        }
    }
}
