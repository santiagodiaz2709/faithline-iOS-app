import UIKit
import WebKit

class BibleViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    private var webView: WKWebView?
    private var loader: UIActivityIndicatorView?

    private let defaultURLString = "https://faithline.pro/bible"
    private var lastPostedURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Bible"

        setupWebView()
        setupLoader()
        setupRouteTracking()
        loadDefaultPage()
    }

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "routeChanged")
    }

    // MARK: - Setup

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        config.userContentController = userContentController

        let createdWebView = WKWebView(frame: .zero, configuration: config)
        createdWebView.navigationDelegate = self
        createdWebView.translatesAutoresizingMaskIntoConstraints = false
        createdWebView.scrollView.contentInsetAdjustmentBehavior = .never

        view.addSubview(createdWebView)
        self.webView = createdWebView

        NSLayoutConstraint.activate([
            createdWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            createdWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createdWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createdWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupLoader() {
        let createdLoader = UIActivityIndicatorView(style: .large)
        createdLoader.translatesAutoresizingMaskIntoConstraints = false
        createdLoader.hidesWhenStopped = true

        view.addSubview(createdLoader)
        self.loader = createdLoader

        NSLayoutConstraint.activate([
            createdLoader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createdLoader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupRouteTracking() {
        guard let controller = webView?.configuration.userContentController else { return }

        controller.removeScriptMessageHandler(forName: "routeChanged")

        let script = """
        (function() {
            if (window.__iosBibleRouteTrackingInstalled) return;
            window.__iosBibleRouteTrackingInstalled = true;

            function notifyRouteChange() {
                try {
                    window.webkit.messageHandlers.routeChanged.postMessage(window.location.href);
                } catch (e) {
                    console.log("routeChanged error", e);
                }
            }

            const originalPushState = history.pushState;
            history.pushState = function() {
                originalPushState.apply(history, arguments);
                setTimeout(notifyRouteChange, 50);
            };

            const originalReplaceState = history.replaceState;
            history.replaceState = function() {
                originalReplaceState.apply(history, arguments);
                setTimeout(notifyRouteChange, 50);
            };

            window.addEventListener('popstate', function() {
                setTimeout(notifyRouteChange, 50);
            });

            window.addEventListener('hashchange', function() {
                setTimeout(notifyRouteChange, 50);
            });

            document.addEventListener('click', function() {
                setTimeout(notifyRouteChange, 250);
            }, true);

            setTimeout(notifyRouteChange, 300);
            setTimeout(notifyRouteChange, 900);
        })();
        """

        let userScript = WKUserScript(
            source: script,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )

        controller.addUserScript(userScript)
        controller.add(self, name: "routeChanged")
    }

    // MARK: - Page Loading

    func loadDefaultPage() {
        loadViewIfNeeded()

        guard let url = URL(string: defaultURLString) else { return }
        webView?.load(URLRequest(url: url))
    }

    func loadDefaultPageIfNeeded() {
        loadViewIfNeeded()

        let current = webView?.url?.absoluteString.lowercased() ?? ""
        if !current.contains("/bible") {
            loadDefaultPage()
        }
    }

    private func postURLIfNeeded(_ urlString: String) {
        let lower = urlString.lowercased()
        guard lastPostedURL != lower else { return }

        lastPostedURL = lower
        NotificationCenter.default.post(name: .didUpdateCurrentWebURL, object: lower)
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "routeChanged",
              let currentURL = message.body as? String else { return }

        print("Bible JS URL: \(currentURL)")
        postURLIfNeeded(currentURL)
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loader?.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loader?.stopAnimating()

        if let currentURL = webView.url?.absoluteString {
            print("Bible didFinish URL: \(currentURL)")
            postURLIfNeeded(currentURL)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loader?.stopAnimating()
        print("Bible navigation failed: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loader?.stopAnimating()
        print("Bible provisional navigation failed: \(error.localizedDescription)")
    }
}
