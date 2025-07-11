import Foundation

struct AIChatResponseModel: Codable {
    let response: [AITaskModel]
}

struct AITaskModel: Codable {
    let id: Int
    let title: String
    let description: String
    let status: String
    let categoryId: Int
    let dueDate: String
    let dueTime: String

    enum CodingKeys: String, CodingKey {
        case id, title, description, status
        case categoryId = "category_id"
        case dueDate = "due_date"
        case dueTime = "due_time"
    }
}
