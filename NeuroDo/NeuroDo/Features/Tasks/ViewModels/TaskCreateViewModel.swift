import Foundation
import UIKit

final class TaskCreateViewModel {

    var title: String = ""
    var description: String = ""
    var dueDate: Date = Date()
    var dueTime: String = ""
    var selectedCategoryId: Int?

    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    var onCategoriesFetched: (([CategoryModel]) -> Void)?

    private let taskService: TaskServiceProtocol = TaskService.shared
    private let categoryService: CategoryServiceProtocol = CategoryService.shared

    func fetchCategories() {
        categoryService.fetchCategories { [weak self] categories in
            DispatchQueue.main.async {
                self?.selectedCategoryId = categories.first?.id
                self?.onCategoriesFetched?(categories)
            }
        }
    }

    func addTask() {
        if dueTime.isEmpty {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            dueTime = timeFormatter.string(from: Date())
        }

        guard !title.isEmpty else {
            onError?("Görev başlığı boş olamaz.")
            return
        }

        guard let categoryId = selectedCategoryId else {
            onError?("Kategori seçilmedi.")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: dueDate)

        let taskRequest = TaskUpdateRequest(
            title: title,
            description: description,
            status: "active",
            category_id: categoryId,
            due_date: dateString,
            due_time: dueTime
        )

        let endpoint = Endpoint(
            path: "/api/v1/todos/",
            method: .POST,
            body: try? JSONEncoder().encode(taskRequest)
        )

        APIService.shared.request(endpoint: endpoint, responseModel: TaskModel.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    NotificationCenter.default.post(name: .didUpdateTasks, object: nil)
                    self?.onSuccess?()
                case .failure(let error):
                    self?.onError?("Görev oluşturulamadı: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateTask(taskId: Int) {
        if dueTime.isEmpty {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            dueTime = timeFormatter.string(from: Date())
        }

        guard !title.isEmpty else {
            onError?("Başlık boş olamaz.")
            return
        }

        guard let categoryId = selectedCategoryId else {
            onError?("Kategori seçilmedi.")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: dueDate)

        let updateRequest = TaskUpdateRequest(
            title: title,
            description: description,
            status: "active",
            category_id: categoryId,
            due_date: dateString,
            due_time: dueTime
        )

        guard let bodyData = try? JSONEncoder().encode(updateRequest) else {
            onError?("Veri kodlanamadı.")
            return
        }

        let endpoint = Endpoint(
            path: "/api/v1/todos/\(taskId)",
            method: .PUT,
            body: bodyData
        )

        APIService.shared.request(endpoint: endpoint, responseModel: TaskModel.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    NotificationCenter.default.post(name: .didUpdateTasks, object: nil)
                    self?.onSuccess?()
                case .failure(let error):
                    self?.onError?("Görev güncellenemedi: \(error.localizedDescription)")
                }
            }
        }
    }
}
extension Notification.Name {
    static let didUpdateTasks = Notification.Name("didUpdateTasks")
}
