
import Foundation

struct TaskCreateRequest: Encodable {
    let title: String
    let description: String
    let due_date: String 
    let category_id: Int
}
