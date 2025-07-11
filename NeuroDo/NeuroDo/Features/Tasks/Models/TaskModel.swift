import Foundation

struct TaskModel: Codable {
    var id: Int
    var title: String
    var description: String
    var dueDate: String
    var dueTime: String?
    var status: String
    var categoryId: Int
    var createdAt: String?
    var updatedAt: String?
    var userId: Int
    var user: UserModel
    var category: CategoryModel

    enum CodingKeys: String, CodingKey {
        case id, title, description, status
        case dueDate = "due_date"
        case dueTime = "due_time" 
        case categoryId = "category_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userId = "user_id"
        case user, category
    }
}


struct CategoryModel: Codable {
    var id: Int
    var name: String
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
    }
}

struct UserModel: Codable {
    var id: Int
    var email: String
}
