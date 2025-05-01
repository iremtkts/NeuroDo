import Foundation
import UIKit

final class TaskListViewModel {
    
    var tasks: [TaskModel] = [] {
        didSet {
            onTasksUpdated?()
        }
    }
    
    var onTasksUpdated: (() -> Void)?
    
    private let taskService: TaskServiceProtocol
    
    init(taskService: TaskServiceProtocol = MockTaskService.shared) {
        self.taskService = taskService
    }
    
    func fetchTasks() {
        taskService.fetchTasks { [weak self] fetchedTasks in
            self?.tasks = fetchedTasks
        }
    }
    
    func refresh() {
        fetchTasks()
    }
    
    func deleteTask(at index: Int) {
            guard tasks.indices.contains(index) else { return }
            tasks.remove(at: index)
        }
    
    func updateTask(at index: Int, with newTitle: String) {
        tasks[index].title = newTitle
    }


}
