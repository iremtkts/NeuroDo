
import Foundation

struct TaskUpdateRequest: Codable {
    let title: String
    let description: String
    let status: String
    let category_id: Int
    let due_date: String
    let due_time: String
}
