import UIKit

extension Notification.Name {
    static let didUpdateCurrentWebURL = Notification.Name("didUpdateCurrentWebURL")
}

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    private var lastHandledURL: String?
    private var lastHandledTime: TimeInterval = 0
    private var isProgrammaticTabChange = false

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        setupTabs()
        setupAppearance()
        forceBottomTabBar()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWebURLChange(_:)),
            name: .didUpdateCurrentWebURL,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupTabs() {
        let homeVC = MyViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "house.fill")?.withRenderingMode(.alwaysTemplate)
        )

        let bibleVC = BibleViewController()
        let bibleNav = UINavigationController(rootViewController: bibleVC)
        bibleNav.tabBarItem = UITabBarItem(
            title: "Bible",
            image: UIImage(systemName: "book")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "book.fill")?.withRenderingMode(.alwaysTemplate)
        )

        let charactersVC = CharactersViewController()
        let charactersNav = UINavigationController(rootViewController: charactersVC)
        charactersNav.tabBarItem = UITabBarItem(
            title: "Characters",
            image: UIImage(systemName: "person.2")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "person.2.fill")?.withRenderingMode(.alwaysTemplate)
        )

        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: "Info",
            image: UIImage(systemName: "info.circle")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "info.circle.fill")?.withRenderingMode(.alwaysTemplate)
        )

        viewControllers = [homeVC, bibleNav, charactersNav, settingsNav]
    }

    @objc private func handleWebURLChange(_ notification: Notification) {
        guard let urlString = notification.object as? String else { return }

        let lower = urlString.lowercased()
        let now = Date().timeIntervalSince1970

        // Ignore duplicates fired rapidly from KVO + JS + didFinish etc.
        if lastHandledURL == lower, now - lastHandledTime < 0.6 {
            return
        }

        lastHandledURL = lower
        lastHandledTime = now

        print("Current Web URL: \(lower)")

        let targetIndex: Int?

        if lower.contains("/characters") {
            targetIndex = 2
        } else if lower.contains("/bible") || lower.contains("/home") {
            targetIndex = 1
        } else if  lower == "https://faithline.pro/" || lower == "https://faithline.pro" {
            targetIndex = 0
        } else {
            targetIndex = nil
        }

        guard let index = targetIndex, selectedIndex != index else { return }

        isProgrammaticTabChange = true
        selectedIndex = index

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isProgrammaticTabChange = false
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if isProgrammaticTabChange { return }

        if let homeVC = viewController as? MyViewController {
            homeVC.loadViewIfNeeded()
            homeVC.loadHomeIfNeeded()
            return
        }

        if let nav = viewController as? UINavigationController,
           let root = nav.viewControllers.first {

            root.loadViewIfNeeded()

            if let bibleVC = root as? BibleViewController {
                bibleVC.loadDefaultPageIfNeeded()
            } else if let charactersVC = root as? CharactersViewController {
                charactersVC.loadDefaultPageIfNeeded()
            }
        }
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

        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]

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
