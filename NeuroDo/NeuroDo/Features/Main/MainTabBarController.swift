import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        //AI Asistan Sekmesi
        let aiVC = AIChatViewController()
        aiVC.title = "AI Asistan"
        let aiNav = UINavigationController(rootViewController: aiVC)
        aiNav.tabBarItem = UITabBarItem(title: "AI", image: UIImage(systemName: "brain.head.profile"), tag: 0)
        //  Görevler Sekmesi
        let taskListVC = TaskListViewController()
        taskListVC.title = "Görevlerim"
        let taskNav = UINavigationController(rootViewController: taskListVC)
        taskNav.tabBarItem = UITabBarItem(title: "Görevler", image: UIImage(systemName: "checklist"), tag: 1)
       
        //Calendar Sekmesi
        let addTaskVC = CalendarViewController()
        addTaskVC.title = "Takvim"
        let addTaskNav = UINavigationController(rootViewController: addTaskVC)
        addTaskNav.tabBarItem = UITabBarItem(title: "Takvim", image: UIImage(systemName: "calendar"), tag: 2)
        
        // Sekmeleri ekle
        viewControllers = [aiNav, taskNav, addTaskNav]
       

    }
}
