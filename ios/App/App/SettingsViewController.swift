import UIKit
import StoreKit

class SettingsViewController: UITableViewController {

    let items = [
        "About Us",
        "Privacy Policy",
        "Terms & Conditions",
        "Rate App",
        "App Version",
    ]

    private var loaderContainer: UIView?
    private var activityIndicator: UIActivityIndicatorView?

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

        if items[indexPath.row] == "App Version" {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }

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
        case "About Us":
            webVC.urlString = "https://faithline.pro/about"

        case "Privacy Policy":
            webVC.urlString = "https://faithline.pro/privacy-policy"

        case "Terms & Conditions":
            webVC.urlString = "https://faithline.pro/terms-and-conditions"

        case "Rate App":
            showLoader()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }

                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }

                // Apple does not provide callback for popup shown/dismissed.
                // So hide loader after a short delay.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.hideLoader()
                }
            }
            return

        default:
            return
        }

        webVC.title = item
        navigationController?.pushViewController(webVC, animated: true)
    }

    // MARK: - Loader

    private func showLoader() {
        guard loaderContainer == nil else { return }

        let container = UIView(frame: view.bounds)
        container.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let loaderBox = UIView()
        loaderBox.translatesAutoresizingMaskIntoConstraints = false
        loaderBox.backgroundColor = UIColor.white
        loaderBox.layer.cornerRadius = 12

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()

        container.addSubview(loaderBox)
        loaderBox.addSubview(indicator)
        view.addSubview(container)

        NSLayoutConstraint.activate([
            loaderBox.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            loaderBox.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            loaderBox.widthAnchor.constraint(equalToConstant: 100),
            loaderBox.heightAnchor.constraint(equalToConstant: 100),

            indicator.centerXAnchor.constraint(equalTo: loaderBox.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: loaderBox.centerYAnchor)
        ])

        loaderContainer = container
        activityIndicator = indicator
    }

    private func hideLoader() {
        activityIndicator?.stopAnimating()
        loaderContainer?.removeFromSuperview()
        loaderContainer = nil
        activityIndicator = nil
    }
}
