import Foundation

protocol MoodAnalyzerProtocol {
    func analyzeMood(from text: String, completion: @escaping (MoodAnalysisResponse) -> Void)
}

final class MockMoodAnalyzer: MoodAnalyzerProtocol {
    func analyzeMood(from text: String, completion: @escaping (MoodAnalysisResponse) -> Void) {
        // Sadece örnek veri döner
        let response = MoodAnalysisResponse(
            mood: "Stresli",
            suggestions: [
                "5 dk meditasyon yap",
                "Derin nefes egzersizi dene",
                "Kısa yürüyüşe çık"
            ]
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(response)
        }
    }
}
