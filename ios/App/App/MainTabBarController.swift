import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabs()
        setupAppearance()
    }

    func setupTabs() {

        // Home (Capacitor WebView)
        let homeVC = MyViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "house.fill")?.withRenderingMode(.alwaysTemplate)
        )

        // Bible (WebViewController)
        let bibleVC = BibleViewController()
        let bibleNav = UINavigationController(rootViewController: bibleVC)
        bibleNav.tabBarItem = UITabBarItem(
            title: "Bible",
            image: UIImage(systemName: "book")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "book.fill")?.withRenderingMode(.alwaysTemplate)
        )

        // Settings
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: "Info",
            image: UIImage(systemName: "info.circle")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "info.circle.fill")?.withRenderingMode(.alwaysTemplate)
        )

        viewControllers = [homeVC, bibleNav, settingsNav]
    }

    func setupAppearance1() {
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.clear

        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.black
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .white
        
        tabBar.isTranslucent = false
        tabBar.backgroundColor = Theme.primaryColor
        tabBar.layer.borderWidth = 0
        tabBar.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    func setupAppearance() {

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.primaryColor

        // Selected
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]

        // Unselected (lighter white instead of black)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.65)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.65),
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.65)
        tabBar.backgroundColor = Theme.primaryColor

        tabBar.isTranslucent = false
        tabBar.layer.borderWidth = 0
    }
    
}
