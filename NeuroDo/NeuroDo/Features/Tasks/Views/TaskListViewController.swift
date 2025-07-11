import UIKit

final class TaskListViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let tableView = UITableView()
    private let statusImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "3"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        return imageView
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Durum mesajı yükleniyor..."
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - ViewModel
    
    private let viewModel = TaskListViewModel()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchTasks()
        viewModel.checkTaskStatus()
        setupLogoutButton()
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
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

        let headerStack = UIStackView(arrangedSubviews: [statusImageView, statusLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 12
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        let headerContainer = UIView()
        headerContainer.addSubview(headerStack)
        headerContainer.frame.size.height = 260

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 16),
            headerStack.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -16),
            headerStack.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16)
        ])

        tableView.tableHeaderView = headerContainer
    }

    private func setupBindings() {
        viewModel.onTasksUpdated = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.onStatusMessageUpdate = { [weak self] msg in
            self?.statusLabel.text = msg
        }
    }

    

    private func setupLogoutButton() {
        let powerButton = UIBarButtonItem(
            image: UIImage(systemName: "power"),
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        powerButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = powerButton
    }

    @objc private func logoutTapped() {
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = nav
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }

        let task = viewModel.task(at: indexPath)

        let softColors: [UIColor] = [
            .systemPink.withAlphaComponent(0.3),
            .systemBlue.withAlphaComponent(0.3),
            .systemGreen.withAlphaComponent(0.3),
            .systemOrange.withAlphaComponent(0.3),
            .systemPurple.withAlphaComponent(0.3),
            .systemTeal.withAlphaComponent(0.3)
        ]
        let borderColor = softColors[indexPath.row % softColors.count]

        cell.configure(with: task, borderColor: borderColor)
        return cell
    }



    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForSection(section)
    }

   

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.masksToBounds = true
        cell.contentView.backgroundColor = UIColor.white
        cell.backgroundColor = .clear
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, completion in
            self?.viewModel.deleteTask(at: indexPath)
            

            completion(true)
            self?.viewModel.refresh()
        }

        let completeAction = UIContextualAction(style: .normal, title: "Tamamlandı") { [weak self] _, _, completion in
            self?.viewModel.markTaskAsCompleted(at: indexPath)
            

            completion(true)
            tableView.reloadData()
        }

        completeAction.backgroundColor = UIColor.systemGreen
        return UISwipeActionsConfiguration(actions: [completeAction, deleteAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Düzenle") { [weak self] _, _, completion in
            guard let self = self else { return }
            let task = self.viewModel.task(at: indexPath)
            let editVC = TaskCreateViewController()
            editVC.editingTask = task
            self.navigationController?.pushViewController(editVC, animated: true)
            completion(true)
        }

        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [editAction])
    }
}
