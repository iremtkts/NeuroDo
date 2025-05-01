import Foundation

struct MoodAnalysisResponse: Codable {
    let mood: String
    let suggestions: [String]
}
