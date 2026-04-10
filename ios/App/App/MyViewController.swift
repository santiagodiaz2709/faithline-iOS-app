import UIKit
import Capacitor
import WebKit

class MyViewController: CAPBridgeViewController, WKScriptMessageHandler, WKNavigationDelegate {

    private var loadingView: UIView!
    private var loader: UIActivityIndicatorView!

    override open func viewDidLoad() {
        super.viewDidLoad()

        guard let webView = self.webView else { return }

        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWeb), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        setupLoader()
        showLoader()
        injectRouteTrackingScript()
    }

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "routeChanged")
    }

    @objc func refreshWeb(_ sender: UIRefreshControl) {
        webView?.reload()
        sender.endRefreshing()
    }
    
    func loadHomeIfNeeded() {
        guard let webView = self.webView else { return }

        let current = webView.url?.absoluteString.lowercased() ?? ""
        if !current.contains("/home") && current != "https://faithline.pro/" && current != "https://faithline.pro" {
            if let url = URL(string: "https://faithline.pro/home") {
                webView.load(URLRequest(url: url))
            }
        }
    }

    private func setupLoader() {
        loadingView = UIView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.backgroundColor = UIColor.white
        loadingView.isHidden = false
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        loader = UIActivityIndicatorView(style: .large)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = Theme.primaryColor
        loadingView.addSubview(loader)

        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ])
    }

    private func showLoader() {
        loadingView.isHidden = false
        view.bringSubviewToFront(loadingView)
        loader.startAnimating()
    }

    private func hideLoader() {
        loader.stopAnimating()
        loadingView.isHidden = true
    }

    private func notifyCurrentURL(_ urlString: String) {
        NotificationCenter.default.post(name: .didUpdateCurrentWebURL, object: urlString)
    }

    private func injectRouteTrackingScript() {
        guard let webView = self.webView else { return }

        let userContentController = webView.configuration.userContentController
        userContentController.removeScriptMessageHandler(forName: "routeChanged")
        userContentController.add(self, name: "routeChanged")

        let js = """
        (function() {
            if (window.__iosRouteTrackerInstalled) return;
            window.__iosRouteTrackerInstalled = true;

            function sendRoute() {
                try {
                    window.webkit.messageHandlers.routeChanged.postMessage(window.location.href);
                } catch (e) {
                    console.log('routeChanged postMessage failed', e);
                }
            }

            const originalPushState = history.pushState;
            history.pushState = function() {
                originalPushState.apply(history, arguments);
                setTimeout(sendRoute, 0);
            };

            const originalReplaceState = history.replaceState;
            history.replaceState = function() {
                originalReplaceState.apply(history, arguments);
                setTimeout(sendRoute, 0);
            };

            window.addEventListener('popstate', function() {
                setTimeout(sendRoute, 0);
            });

            window.addEventListener('hashchange', function() {
                setTimeout(sendRoute, 0);
            });

            document.addEventListener('click', function() {
                setTimeout(sendRoute, 300);
            }, true);

            setTimeout(sendRoute, 0);
            setTimeout(sendRoute, 500);
            setTimeout(sendRoute, 1500);
        })();
        """

        let script = WKUserScript(source: js,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: false)

        userContentController.addUserScript(script)
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if message.name == "routeChanged",
           let urlString = message.body as? String {
            print("JS route changed: \(urlString)")
            notifyCurrentURL(urlString)
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showLoader()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = """
        (function() {
          try {
            const desiredViewport = 'width=device-width, initial-scale=1, viewport-fit=cover';
            let meta = document.querySelector('meta[name="viewport"]');

            if (meta) {
              meta.setAttribute('content', desiredViewport);
            } else {
              meta = document.createElement('meta');
              meta.setAttribute('name', 'viewport');
              meta.setAttribute('content', desiredViewport);
              document.head.appendChild(meta);
            }

            const styleId = 'faithline-ios-safearea-fix';
            let style = document.getElementById(styleId);

            if (!style) {
              style = document.createElement('style');
              style.id = styleId;
              document.head.appendChild(style);
            }

            style.innerHTML = `
              html, body {
                margin: 0 !important;
                padding: 0 !important;
                overflow-x: hidden !important;
              }

              header, nav, .navbar, .site-header, .topbar, .header, .nav {
                padding-top: max(0px, calc(env(safe-area-inset-top, 0px) - 10px)) !important;
                box-sizing: border-box !important;
              }
            `;
          } catch (e) {
            console.log('Safe-area injection failed', e);
          }
        })();
        """

        webView.evaluateJavaScript(js) { _, error in
            if let error = error {
                print("JS/CSS injection error: \(error)")
            } else {
                print("Safe-area patch injected successfully")
            }

            self.hideLoader()

            if let currentURL = webView.url?.absoluteString {
                self.notifyCurrentURL(currentURL)
            }

            webView.evaluateJavaScript("window.location.href") { result, _ in
                if let urlString = result as? String {
                    self.notifyCurrentURL(urlString)
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideLoader()
        showError()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideLoader()
        showError()
    }

    func showError() {
        let alert = UIAlertController(
            title: "Connection Error",
            message: "Please check your internet connection and try again.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            self.webView?.reload()
        })

        present(alert, animated: true)
    }
}
