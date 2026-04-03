import UIKit
import WebKit

class BibleViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var loader: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Bible"

        // Create WebView
        webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Loader
        loader = UIActivityIndicatorView(style: .large)
        loader.center = view.center
        loader.color = Theme.primaryColor
        loader.startAnimating()
        view.addSubview(loader)

        // Load URL
        if let url = URL(string: "https://faithline.pro/home") {
            webView.load(URLRequest(url: url))
        }
    }

    // Stop loader when page loads
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loader.stopAnimating()
        loader.removeFromSuperview()
    }
}
