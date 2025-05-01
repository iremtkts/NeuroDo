import Foundation

final class TaskCreateViewModel {
    
    var title: String = ""
    var description: String = ""
    
    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private let taskService: TaskServiceProtocol = MockTaskService.shared
    
    func addTask() {
        guard !title.isEmpty else {
            onError?("Görev başlığı boş olamaz.")
            return
        }
        
        let newTask = TaskModel(
            id: UUID().hashValue,
            title: title,
            isCompleted: false
        )
        
        taskService.addTask(task: newTask) {
            self.onSuccess?()
        }
    }
}
