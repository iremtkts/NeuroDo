import UIKit

final class TaskCreateViewController: UIViewController {

    // MARK: - UI Elements

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "8"))
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return imageView
    }()

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Görev Başlığı"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Açıklama (isteğe bağlı)"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private let dueDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .systemGreen
        return picker
    }()

    private let categoryPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Görev Ekle", for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()

    // MARK: - ViewModel

    private let viewModel = TaskCreateViewModel()
    private var categories: [CategoryModel] = []
    private var selectedCategoryId: Int?

    // MARK: - Düzenleme Modu Desteği

    var editingTask: TaskModel?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchCategories()

        categoryPicker.delegate = self
        categoryPicker.dataSource = self

        configureIfEditing()
    }

    private func configureIfEditing() {
        guard let task = editingTask else { return }

        title = "Görev Düzenle"
        addButton.setTitle("Kaydet", for: .normal)

        titleTextField.text = task.title
        descriptionTextField.text = task.description
        selectedCategoryId = task.categoryId

        if let index = categories.firstIndex(where: { $0.id == task.categoryId }) {
            categoryPicker.selectRow(index, inComponent: 0, animated: false)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: task.dueDate) {
            dueDatePicker.date = date
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        title = "Görev Ekle"
        view.backgroundColor = .systemBackground

        let horizontalStack = UIStackView(arrangedSubviews: [dueDatePicker, categoryPicker])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.distribution = .fillEqually

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            titleTextField,
            descriptionTextField,
            horizontalStack,
            addButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.onCategoriesFetched = { [weak self] fetchedCategories in
            self?.categories = fetchedCategories
            self?.selectedCategoryId = fetchedCategories.first?.id
            self?.categoryPicker.reloadAllComponents()
            self?.configureIfEditing() // kategoriler geldikten sonra picker seçimi yapılmalı
        }

        viewModel.onSuccess = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.onError = { [weak self] error in
            self?.showAlert(title: "Hata", message: error)
        }
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(title: "Hata", message: "Başlık boş olamaz.")
            return
        }

        viewModel.title = title
        viewModel.description = descriptionTextField.text ?? ""
        viewModel.dueDate = dueDatePicker.date
        viewModel.selectedCategoryId = selectedCategoryId

        if let task = editingTask {
            viewModel.updateTask(taskId: task.id)
        } else {
            viewModel.addTask()
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Tamam", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDelegate & DataSource

extension TaskCreateViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        categories[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategoryId = categories[row].id
    }
}
