import Foundation

protocol TaskServiceProtocol {
    func fetchTasks(completion: @escaping ([TaskModel]) -> Void)
    func addTask(task: TaskModel, completion: @escaping () -> Void)
}

final class MockTaskService: TaskServiceProtocol {
    
    static let shared = MockTaskService() 
    private init() {}
    
    private var tasks: [TaskModel] = [
        TaskModel(id: 1, title: "Sunum hazırla", isCompleted: false),
        TaskModel(id: 2, title: "Kitap oku", isCompleted: true)
    ]
    
    func fetchTasks(completion: @escaping ([TaskModel]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion(self.tasks)
        }
    }
    
    func addTask(task: TaskModel, completion: @escaping () -> Void) {
        tasks.append(task)
        completion()
    }
}
