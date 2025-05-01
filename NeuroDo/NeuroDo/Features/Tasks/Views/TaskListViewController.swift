import UIKit

final class TaskListViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let tableView = UITableView()
    
    // MARK: - ViewModel
    
    private let viewModel = TaskListViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }

    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Görevlerim"
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.onTasksUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func presentEditAlert(for index: Int) {
        let task = viewModel.tasks[index]
        let alert = UIAlertController(title: "Görev Düzenle", message: nil, preferredStyle: .alert)
        
        alert.addTextField { $0.text = task.title }

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Kaydet", style: .default, handler: { [weak self] _ in
            guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else { return }
            self?.viewModel.updateTask(at: index, with: newTitle)
            self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }))
        
        present(alert, animated: true)
    }

}

// MARK: - UITableViewDataSource & Delegate

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = viewModel.tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        cell.textLabel?.text = task.title
        return cell
    }
    
    // MARK: - UITableView Swipe Actions

    // Sağdan sola kaydır: Sil
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, completion in
              self?.viewModel.deleteTask(at: indexPath.row)
              completion(true)
          }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // Soldan sağa kaydır: Düzenle
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Düzenle") { [weak self] _, _, completion in
            self?.presentEditAlert(for: indexPath.row)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [editAction])
    }

}
