import Foundation

final class TaskCreateViewModel {
    
    var title: String = ""
    var description: String = ""
    var dueDate: Date = Date()
    var selectedCategoryId: Int?

    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    var onCategoriesFetched: (([CategoryModel]) -> Void)?

    private let taskService: TaskServiceProtocol = TaskService.shared
    private let categoryService: CategoryServiceProtocol = CategoryService.shared

    func fetchCategories() {
        categoryService.fetchCategories { [weak self] categories in
            DispatchQueue.main.async {
                self?.selectedCategoryId = categories.first?.id // default olarak ilk kategori
                self?.onCategoriesFetched?(categories)
            }
        }
    }

    func addTask() {
        guard !title.isEmpty else {
            onError?("Görev başlığı boş olamaz.")
            return
        }

        guard let categoryId = selectedCategoryId else {
            onError?("Kategori seçilmedi.")
            return
        }
        let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: dueDate)

            let taskRequest = TaskCreateRequest(
                title: title,
                description: description,
                due_date: dateString, 
                category_id: categoryId
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
                    self?.onSuccess?()
                case .failure(let error):
                    self?.onError?("Görev oluşturulamadı: \(error.localizedDescription)")
                }
            }
        }
    }
}
