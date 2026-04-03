import UIKit

class SettingsViewController: UITableViewController {

    let items = [
        "About Us",
        "Privacy Policy",
        "Terms & Conditions",
        "Contact Us",
        "App Version"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
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
        } else {
            let vc = UIViewController()
            vc.view.backgroundColor = .systemBackground
            vc.title = item
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
