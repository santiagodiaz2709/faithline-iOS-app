import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabs()
        setupAppearance()
        forceBottomTabBar()
    }

    func setupTabs() {

        // Home (Capacitor WebView)
        let homeVC = MyViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "house.fill")?.withRenderingMode(.alwaysTemplate)
        )

        // Bible
        let bibleVC = BibleViewController()
        let bibleNav = UINavigationController(rootViewController: bibleVC)
        bibleNav.tabBarItem = UITabBarItem(
            title: "Bible",
            image: UIImage(systemName: "book")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "book.fill")?.withRenderingMode(.alwaysTemplate)
        )
        
        // Bible 
        let charactersVC = CharactersViewController()
        let charactersNav = UINavigationController(rootViewController: charactersVC)
        charactersNav.tabBarItem = UITabBarItem(
            title: "Characters",
            image: UIImage(systemName: "person.2")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "person.2.fill")?.withRenderingMode(.alwaysTemplate)
        )

        // Settings
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: "Info",
            image: UIImage(systemName: "info.circle")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "info.circle.fill")?.withRenderingMode(.alwaysTemplate)
        )

        viewControllers = [homeVC, bibleNav, charactersNav, settingsNav]
    }
    
    func forceBottomTabBar() {
        if #available(iOS 18.0, *) {
            self.traitOverrides.horizontalSizeClass = .compact
        }
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
