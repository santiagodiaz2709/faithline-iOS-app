import UIKit
import WebKit
import AVFoundation

class CharactersViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {

    private var webView: WKWebView?
    private var loader: UIActivityIndicatorView?

    private let defaultURLString = "https://faithline.pro/characters"
    private var lastPostedURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Characters"

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
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let createdWebView = WKWebView(frame: .zero, configuration: config)
        createdWebView.navigationDelegate = self
        createdWebView.uiDelegate = self
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
        createdLoader.color = Theme.primaryColor

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
            if (window.__iosCharactersRouteTrackingInstalled) return;
            window.__iosCharactersRouteTrackingInstalled = true;

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
        if !current.contains("/characters") {
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

        print("Characters JS URL: \(currentURL)")
        postURLIfNeeded(currentURL)
    }

    @available(iOS 15.0, *)
    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        guard type == .microphone || type == .cameraAndMicrophone else {
            decisionHandler(.deny)
            return
        }
        // AVAudioSession.requestRecordPermission triggers the iOS system
        // "FaithLine wants to access your microphone" dialog on first use.
        // decisionHandler(.grant) bypasses this dialog and silently fails.
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                decisionHandler(granted ? .grant : .deny)
            }
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loader?.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loader?.stopAnimating()

        injectJavaScriptErrorLogger(into: webView)

        if let currentURL = webView.url?.absoluteString {
            print("Characters didFinish URL: \(currentURL)")
            postURLIfNeeded(currentURL)
        }
    }

    private func injectJavaScriptErrorLogger(into webView: WKWebView) {
        let js = """
        (function() {
            if (window.__faithlineErrorLoggerInstalled) return;
            window.__faithlineErrorLoggerInstalled = true;

            window.onerror = function(message, source, lineno, colno, error) {
                console.log("FAITHLINE_JS_ERROR:", message, source, lineno, colno);
            };

            window.addEventListener('unhandledrejection', function(event) {
                console.log("FAITHLINE_JS_PROMISE_ERROR:", event.reason);
            });
        })();
        """

        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loader?.stopAnimating()
        print("Characters navigation failed: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loader?.stopAnimating()
        print("Characters provisional navigation failed: \(error.localizedDescription)")
    }
}

