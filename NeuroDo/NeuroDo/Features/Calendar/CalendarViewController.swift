//
//  CalendarViewController.swift
//  NeuroDo
//
//  Created by iremt on 10.07.2025.
//
import UIKit
import Foundation
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    private var calendar: FSCalendar!
    private var tasksByDate: [String: [TaskModel]] = [:] 
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCalendar()
        fetchTasks()
    }

    private func setupCalendar() {
        calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.todayColor = .systemPurple
        calendar.appearance.selectionColor = .systemIndigo
        calendar.appearance.eventDefaultColor = .systemPurple
        calendar.appearance.titleTodayColor = .white
        calendar.appearance.borderRadius = 1.0
        calendar.appearance.headerTitleColor = .systemIndigo
        calendar.appearance.weekdayTextColor = .darkGray
        
        view.addSubview(calendar)
        
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendar.heightAnchor.constraint(equalToConstant: 400)
        ])
    }

    private func fetchTasks() {
        TaskService.shared.fetchTasks { [weak self] tasks in
            guard let self = self else { return }
            for task in tasks {
                let key = task.dueDate // "yyyy-MM-dd"
                self.tasksByDate[key, default: []].append(task)
            }
            DispatchQueue.main.async {
                self.calendar.reloadData()
            }
        }
    }

    // MARK: - FSCalendarDataSource

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let key = dateFormatter.string(from: date)
        return tasksByDate[key]?.count ?? 0
    }

    // MARK: - FSCalendarDelegate

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let key = dateFormatter.string(from: date)
        guard let tasks = tasksByDate[key], !tasks.isEmpty else {
            showAlert(title: "Görev Yok", message: "Bu tarihte görev bulunmamaktadır.")
            return
        }

        var message = ""
        for task in tasks {
            message += "📌 \(task.title)\n⏰ \(task.dueTime)\nDurum: \(task.status.capitalized)\n\n"
        }
        showAlert(title: key, message: message)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}
