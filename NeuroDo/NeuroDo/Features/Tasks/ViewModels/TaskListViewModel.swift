import Foundation
import UIKit


final class TaskListViewModel {

    // MARK: - Servisler

    private let taskService: TaskServiceProtocol
    private let categoryService: CategoryServiceProtocol

    // MARK: - Callback'ler (ViewController ile haberleşme)

    var onTasksUpdated: (() -> Void)?
    var onStatusMessageUpdate: ((String) -> Void)?

    // MARK: - Veriler

    private(set) var tasks: [TaskModel] = [] {
        didSet {
            groupTasksByDate()
        }
    }

    private(set) var categories: [CategoryModel] = []

    private(set) var groupedTasks: [(title: String, tasks: [TaskModel])] = []

    // MARK: - Başlatıcı

    init(
        taskService: TaskServiceProtocol = TaskService.shared,
        categoryService: CategoryServiceProtocol = CategoryService.shared
    ) {
        self.taskService = taskService
        self.categoryService = categoryService
    }

    // MARK: - Görevleri ve Kategorileri Getir

    func fetchTasks() {
      
        categoryService.fetchCategories { [weak self] fetchedCategories in
            self?.categories = fetchedCategories

           
            self?.taskService.fetchTasks { [weak self] fetchedTasks in
                DispatchQueue.main.async {
                    self?.tasks = fetchedTasks
                }
            }
        }
    }

    func refresh() {
        fetchTasks()
    }

    // MARK: - Gecikmiş Görev Kontrolü

    func checkTaskStatus() {
        taskService.fetchOverdueTasks { [weak self] overdue in
            DispatchQueue.main.async {
                let msg = overdue.isEmpty
                    ? "Bu hafta tamamlaman gereken görevleri yaptın! 🎉"
                    : "Hadi! \(overdue.count) görevin gecikti, birlikte toparlayabiliriz 💪"
                self?.onStatusMessageUpdate?(msg)
            }
        }
    }

    // MARK: - Görev Güncelleme ve Silme

    func deleteTask(at indexPath: IndexPath) {
        guard indexPath.section < groupedTasks.count,
              indexPath.row < groupedTasks[indexPath.section].tasks.count else { return }

        let taskToRemove = groupedTasks[indexPath.section].tasks[indexPath.row]

        taskService.deleteTask(taskId: taskToRemove.id) { [weak self] success in
            guard success else { return }

            DispatchQueue.main.async {
                self?.fetchTasks()
            }
        }
    }



    func updateTask(at indexPath: IndexPath, with newTitle: String) {
        guard indexPath.section < groupedTasks.count,
              indexPath.row < groupedTasks[indexPath.section].tasks.count else { return }

        let taskToUpdate = groupedTasks[indexPath.section].tasks[indexPath.row]
        if let indexInFlatList = tasks.firstIndex(where: { $0.id == taskToUpdate.id }) {
            tasks[indexInFlatList].title = newTitle
        }
    }

    func markTaskAsCompleted(at indexPath: IndexPath) {
        let task = groupedTasks[indexPath.section].tasks[indexPath.row]
        taskService.markTaskAsCompleted(taskId: task.id) { [weak self] success in
            guard success else { return }
            DispatchQueue.main.async {
                self?.fetchTasks() 
            }
        }
    }


    // MARK: - Yardımcı Fonksiyonlar (TableView için)

    func task(at indexPath: IndexPath) -> TaskModel {
        return groupedTasks[indexPath.section].tasks[indexPath.row]
    }


    func numberOfSections() -> Int {
        return groupedTasks.count
    }

    func numberOfRows(in section: Int) -> Int {
        return groupedTasks[section].tasks.count
    }

    func titleForSection(_ section: Int) -> String {
        return groupedTasks[section].title
    }

    // MARK: - Tarihe Göre Görev Gruplama

    private func groupTasksByDate() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let past = tasks.filter {
            guard let date = formatter.date(from: $0.dueDate) else { return false }
            return calendar.startOfDay(for: date) < today
        }

        let todayTasks = tasks.filter {
            guard let date = formatter.date(from: $0.dueDate) else { return false }
            return calendar.isDateInToday(date)
        }

        let future = tasks.filter {
            guard let date = formatter.date(from: $0.dueDate) else { return false }
            return calendar.startOfDay(for: date) > today
        }

        var result: [(title: String, tasks: [TaskModel])] = []

        if !past.isEmpty {
            result.append((title: "Geçmiş Görevler", tasks: past))
        }

        if !todayTasks.isEmpty {
            result.append((title: "Bugünkü Görevler", tasks: todayTasks))
        }

        if !future.isEmpty {
            result.append((title: "Yaklaşan Görevler", tasks: future))
        }

        self.groupedTasks = result

       
        DispatchQueue.main.async {
            self.onTasksUpdated?()
        }
    }



}
