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

    
    private func presentEditAlert(for indexPath: IndexPath) {
        let task = viewModel.task(at: indexPath)
        let alert = UIAlertController(title: "Görev Düzenle", message: nil, preferredStyle: .alert)

        alert.addTextField { $0.text = task.title }

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Kaydet", style: .default, handler: { [weak self] _ in
            guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else { return }
            self?.viewModel.updateTask(at: indexPath, with: newTitle)
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }))

        present(alert, animated: true)
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
       

        // Login ekranını yeniden root yap
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = viewModel.task(at: indexPath)

      
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        // Renk paleti (soft renkler)
        let softColors: [UIColor] = [
            .systemPink.withAlphaComponent(0.3),
            .systemBlue.withAlphaComponent(0.3),
            .systemGreen.withAlphaComponent(0.3),
            .systemOrange.withAlphaComponent(0.3),
            .systemPurple.withAlphaComponent(0.3),
            .systemTeal.withAlphaComponent(0.3)
        ]
        let borderColor = softColors[indexPath.row % softColors.count]

        // Arka plan kutusu
        let bgView = UIView()
        bgView.layer.cornerRadius = 12
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = borderColor.cgColor
        bgView.layer.masksToBounds = true
        bgView.translatesAutoresizingMaskIntoConstraints = false

        // Başlık label
        let titleLabel = UILabel()
        titleLabel.text = task.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

      

        // Kategori label
        let categoryLabel = UILabel()
        categoryLabel.text = "📂 \(task.category.name ?? "Kategori yok")"
        categoryLabel.font = .systemFont(ofSize: 13, weight: .medium)
        categoryLabel.textColor = .darkGray
        categoryLabel.textAlignment = .right
        categoryLabel.numberOfLines = 1

        // StackView ile düzenle
        let stack = UIStackView(arrangedSubviews: [titleLabel, categoryLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setContentHuggingPriority(.required, for: .vertical)
        stack.setContentCompressionResistancePriority(.required, for: .vertical)

        // Yerleşim
        bgView.addSubview(stack)
        cell.contentView.addSubview(bgView)

        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            bgView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
            bgView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            bgView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -12)
        ])

        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }



    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForSection(section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.masksToBounds = true
        cell.contentView.backgroundColor = UIColor.white
        cell.backgroundColor = .clear
    }

    
    // MARK: - UITableView Swipe Actions

    // Sağdan sola kaydır: Sil
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, completion in
            self?.viewModel.deleteTask(at: indexPath)
            completion(true)
        }
        
        let completeAction = UIContextualAction(style: .normal, title: "Tamamlandı") { [weak self] _, _, completion in
            self?.viewModel.markTaskAsCompleted(at: indexPath)
            tableView.reloadData() 
            completion(true)
        }

        
        completeAction.backgroundColor = UIColor.systemGreen

        
        return UISwipeActionsConfiguration(actions: [completeAction, deleteAction])
    }


    // Soldan sağa kaydır: Düzenle
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Düzenle") { [weak self] _, _, completion in
            self?.presentEditAlert(for: indexPath)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [editAction])
    }

}
