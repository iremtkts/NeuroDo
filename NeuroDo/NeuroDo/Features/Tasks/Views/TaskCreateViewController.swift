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


        // MARK: - Lifecycle

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupBindings()
            viewModel.fetchCategories()

            categoryPicker.delegate = self
            categoryPicker.dataSource = self
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
            }

            viewModel.onSuccess = { [weak self] in
                self?.showAlert(title: "Başarılı", message: "Görev eklendi!") {
                    self?.tabBarController?.selectedIndex = 0
                }
            }

            viewModel.onError = { [weak self] error in
                self?.showAlert(title: "Hata", message: error)
            }
        }

        // MARK: - Actions

        @objc private func addButtonTapped() {
            viewModel.title = titleTextField.text ?? ""
            viewModel.description = descriptionTextField.text ?? ""
            viewModel.dueDate = dueDatePicker.date
            viewModel.selectedCategoryId = selectedCategoryId
            viewModel.addTask()


            titleTextField.text = ""
            descriptionTextField.text = ""
            dueDatePicker.date = Date()
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategoryId = categories[row].id
    }
}
