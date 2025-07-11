import Foundation

protocol AIChatServiceProtocol {
    func sendChatMessage(_ message: String, completion: @escaping (Bool) -> Void)
}

final class AIChatService {
    static let shared = AIChatService()
    private init() {}

    func sendChatMessage(_ message: String, completion: @escaping (Bool) -> Void) {
        guard let token = TokenManager.shared.getAuthorizationHeader() else {
            print("🔴 Token bulunamadı")
            completion(false)
            return
        }

        let body = ["message": message]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("❌ JSON verisi oluşturulamadı")
            completion(false)
            return
        }

        let endpoint = Endpoint(
            path: "/api/v1/ai/chat",
            method: .POST,
            headers: [
                "Authorization": token,
                "Content-Type": "application/json"
            ],
            body: jsonData
        )

        APIService.shared.request(endpoint: endpoint, responseModel: AIChatResponseModel.self) { result in
            switch result {
            case .success(let response):
                print("🟢 AI yanıtı geldi: \(response.response)")
                self.saveTasksToBackend(tasks: response.response, token: token, completion: completion)
            case .failure(let error):
                print("🔴 AI isteği başarısız: \(error)")
                completion(false)
            }
        }
    }

    private func saveTasksToBackend(tasks: [AITaskModel], token: String, completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()

        TaskService.shared.fetchTasks { existingTasks in
            let filteredTasks = tasks.filter { task in
                !existingTasks.contains(where: {
                    $0.title == task.title &&
                    $0.dueDate == task.dueDate &&
                    $0.dueTime == task.dueTime
                })
            }

            for task in filteredTasks {
                group.enter()
                let todo: [String: Any] = [
                    "title": task.title,
                    "description": task.description,
                    "status": task.status,
                    "category_id": task.categoryId,
                    "due_date": task.dueDate,
                    "due_time": task.dueTime
                ]

                guard let jsonData = try? JSONSerialization.data(withJSONObject: todo) else {
                    group.leave()
                    continue
                }

                let endpoint = Endpoint(
                    path: "/api/v1/todos/",
                    method: .POST,
                    headers: [
                        "Authorization": token,
                        "Content-Type": "application/json"
                    ],
                    body: jsonData
                )

                APIService.shared.request(endpoint: endpoint, responseModel: TaskModel.self) { result in
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(true)
            }
        }
    }

}
extension AIChatService: AIChatServiceProtocol {}
