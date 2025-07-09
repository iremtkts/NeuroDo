//
//  TaskService.swift
//  NeuroDo
//
//  Created by iremt on 1.05.2025.
//

import Foundation

protocol TaskServiceProtocol {
    func fetchTasks(completion: @escaping ([TaskModel]) -> Void)
    func fetchOverdueTasks(completion: @escaping ([TaskModel]) -> Void)
    func markTaskAsCompleted(taskId: Int, completion: @escaping (Bool) -> Void)
    func deleteTask(taskId: Int, completion: @escaping (Bool) -> Void)
}

final class TaskService: TaskServiceProtocol {
    func deleteTask(taskId: Int, completion: @escaping (Bool) -> Void) {
        let path = "/api/v1/todos/\(taskId)"
        let endpoint = Endpoint(path: path, method: .DELETE)

        APIService.shared.request(endpoint: endpoint, responseModel: EmptyResponse.self) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Görev silinirken hata: \(error)")
                completion(false)
            }
        }
    }

    
    static let shared = TaskService()
    private init() {}

    func fetchTasks(completion: @escaping ([TaskModel]) -> Void) {
        let endpoint = Endpoint(path: "/api/v1/todos/", method: .GET)

        APIService.shared.request(endpoint: endpoint, responseModel: [TaskModel].self) { result in
            switch result {
            case .success(let tasks):
                completion(tasks)
            case .failure(let error):
                print("Görevleri alırken hata: \(error)")
                completion([])
            }
        }
    }

    func fetchOverdueTasks(completion: @escaping ([TaskModel]) -> Void) {
        let endpoint = Endpoint(path: "/api/v1/todos/overdue", method: .GET)

        APIService.shared.request(endpoint: endpoint, responseModel: [TaskModel].self) { result in
            switch result {
            case .success(let tasks):
                completion(tasks)
            case .failure(let error):
                print("Gecikmiş görevleri alırken hata: \(error)")
                completion([])
            }
        }
    }
    
    func markTaskAsCompleted(taskId: Int, completion: @escaping (Bool) -> Void) {
        let path = "/todos/\(taskId)"
        let method: HTTPMethod = .PATCH

        let bodyDict: [String: String] = ["status": "completed"]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict) else {
            completion(false)
            return
        }

        let endpoint = Endpoint(path: path, method: method, body: bodyData)

        APIService.shared.request(endpoint: endpoint, responseModel: EmptyResponse.self) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Görev tamamlama hatası: \(error)")
                completion(false)
            }
        }
    }


}
struct EmptyResponse: Codable {}
