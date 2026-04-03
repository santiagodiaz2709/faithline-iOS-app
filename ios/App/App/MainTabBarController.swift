import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Home
        let homeVC = MyViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            tag: 0
        )

        // Subscription
        let subscriptionVC = SubscriptionViewController()
        let subNav = UINavigationController(rootViewController: subscriptionVC)
        subNav.tabBarItem = UITabBarItem(
            title: "Subscription",
            image: UIImage(systemName: "creditcard"),
            tag: 1
        )

        // Settings
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            tag: 2
        )

        viewControllers = [homeVC, subNav, settingsNav]
    }
}
