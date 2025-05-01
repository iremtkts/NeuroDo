import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        // 1. Görevler Sekmesi
        let taskListVC = TaskListViewController()
        taskListVC.title = "Görevlerim"
        let taskNav = UINavigationController(rootViewController: taskListVC)
        taskNav.tabBarItem = UITabBarItem(title: "Görevler", image: UIImage(systemName: "checklist"), tag: 0)
        
        // 2. AI Asistan Sekmesi
        let aiVC = AIAssistantViewController()
        aiVC.title = "AI Asistan"
        let aiNav = UINavigationController(rootViewController: aiVC)
        aiNav.tabBarItem = UITabBarItem(title: "AI", image: UIImage(systemName: "brain.head.profile"), tag: 1)
        
        // 3. Görev Ekle Sekmesi
        let addTaskVC = TaskCreateViewController()
        addTaskVC.title = "Görev Ekle"
        let addTaskNav = UINavigationController(rootViewController: addTaskVC)
        addTaskNav.tabBarItem = UITabBarItem(title: "Ekle", image: UIImage(systemName: "plus.circle"), tag: 2)
        
        // Sekmeleri ekle
        viewControllers = [taskNav, aiNav, addTaskNav]
    }
}
