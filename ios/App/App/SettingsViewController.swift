import UIKit
import StoreKit

class SettingsViewController: UITableViewController {

    let items = [
        "Characters",
        "About Us",
        "Privacy Policy",
        "Terms & Conditions",
        "Rate App",
        "App Version",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Info"
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = items[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .black
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let item = items[indexPath.row]

        if item == "App Version" {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let alert = UIAlertController(
                title: "App Version",
                message: version,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let webVC = WebViewController()

        switch item {
        case "Characters":
            webVC.urlString = "https://faithline.pro/characters"
        case "About Us":
            webVC.urlString = "https://faithline.pro/about"
        case "Privacy Policy":
            webVC.urlString = "https://faithline.pro/privacy-policy"
        case "Terms & Conditions":
            webVC.urlString = "https://faithline.pro/terms-and-conditions"
        case "Rate App":
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        default:
            return
        }

        webVC.title = item
        navigationController?.pushViewController(webVC, animated: true)
    }
}
