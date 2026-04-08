import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var urlString: String?
    var webView: WKWebView!
    var loader: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

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

        loader = UIActivityIndicatorView(style: .large)
        loader.center = view.center
        loader.startAnimating()
        view.addSubview(loader)

        if let urlString = urlString,
           let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loader.stopAnimating()
        loader.removeFromSuperview()
    }
}
